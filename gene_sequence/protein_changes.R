###############################################################################
# Do the high-frequency SNPs change the protein?
#
# Takes the SNPs in substituted_snps.tsv (written by gene_sequences.R: the
# SNPs whose ALT frequency in a population was above your threshold), finds
# every transcript in a GTF annotation whose coding sequence (CDS) contains
# one of them, and for each population:
#   1. builds the reference coding sequence from the genome FASTA,
#   2. puts that population's SNPs into it,
#   3. translates both and compares them codon by codon.
#
# Because whole coding sequences are translated, two SNPs in the same codon
# are handled correctly (they are judged together, not one at a time).
#
# Usage:
#   Rscript protein_changes.R genome.fasta annotation.gtf substituted_snps.tsv
#
# Input:
#   - the same genome FASTA used for gene_sequences.R
#   - a GTF for that genome (CDS and, if present, stop_codon lines are used)
#   - substituted_snps.tsv from gene_sequences.R. It only contains SNPs in the
#     genes that script extracted; to check every gene, run gene_sequences.R
#     with your full BED file (or with outliers_only = FALSE).
#
# Output:
#   protein_changes.tsv   one row per codon that changed, per transcript and
#                         population: synonymous, missense, stop_gained,
#                         stop_lost or start_lost
#   protein_summary.tsv   counts per transcript and population
#   proteins.fa           reference and population protein sequences for
#                         every transcript with at least one change
#
# Uses the standard genetic code. Requires only base R.
###############################################################################

# ---- Settings ----------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3)
  stop("Usage: Rscript protein_changes.R genome.fasta annotation.gtf substituted_snps.tsv")
fasta_file <- args[1]
gtf_file   <- args[2]
snp_file   <- args[3]


# ---- Genetic code --------------------------------------------------------------
b <- c("T", "C", "A", "G")
codons <- paste0(rep(b, each = 16), rep(rep(b, each = 4), 4), rep(b, 16))
code   <- setNames(strsplit(
  "FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "")[[1]],
  codons)
translate_codons <- function(cod) { aa <- code[cod]; aa[is.na(aa)] <- "X"; unname(aa) }
to_codons <- function(bases) {
  n <- floor(length(bases) / 3) * 3
  if (n == 0) return(character(0))
  m <- matrix(bases[1:n], nrow = 3)
  paste0(m[1, ], m[2, ], m[3, ])
}
complement <- function(x) chartr("ACGTRYKMBDHVN", "TGCAYRMKVHDBN", x)


# ---- STEP 1: Read the SNPs -------------------------------------------------------
snps <- read.delim(snp_file, stringsAsFactors = FALSE)
snps$CHROM <- sub("^chr", "", snps$CHROM)
# The same SNP appears once per gene it was extracted for; keep it once.
snps <- unique(snps[, c("SPECIES", "CHROM", "POS", "REF", "ALT", "ALT_FREQ")])
pops <- unique(snps$SPECIES)
cat("SNPs:", nrow(snps), "in populations:", paste(pops, collapse = ", "), "\n")


# ---- STEP 2: Read the coding exons from the GTF ---------------------------------
gtf <- read.delim(gtf_file, header = FALSE, comment.char = "#", quote = "",
                  stringsAsFactors = FALSE,
                  col.names = c("CHROM", "SOURCE", "FEATURE", "START", "END",
                                "SCORE", "STRAND", "FRAME", "ATTR"))
gtf <- gtf[gtf$FEATURE %in% c("CDS", "stop_codon"), ]
gtf$CHROM <- sub("^chr", "", gtf$CHROM)

get_attr <- function(attr, key) {
  out <- rep(NA_character_, length(attr))
  hit <- grepl(paste0("(^|; ?)", key, " \""), attr)
  out[hit] <- sub(paste0(".*(^|; ?)", key, " \"([^\"]*)\".*"), "\\2", attr[hit])
  out
}
gtf$TRANSCRIPT <- get_attr(gtf$ATTR, "transcript_id")
gtf$GENE_ID    <- get_attr(gtf$ATTR, "gene_id")
gtf$GENE_NAME  <- get_attr(gtf$ATTR, "gene_name")
no_name <- is.na(gtf$GENE_NAME)
gtf$GENE_NAME[no_name] <- get_attr(gtf$ATTR[no_name], "gene_symbol")   # FlyBase
gtf$GENE_NAME[is.na(gtf$GENE_NAME)] <- gtf$GENE_ID[is.na(gtf$GENE_NAME)]
gtf$FRAME <- suppressWarnings(as.numeric(gtf$FRAME))
gtf$ATTR  <- NULL


# ---- STEP 3: Which transcripts contain at least one SNP in their CDS? -----------
cds <- gtf[gtf$FEATURE == "CDS", ]
hit_tx <- character(0)
for (chr in unique(snps$CHROM)) {
  pos <- sort(unique(snps$POS[snps$CHROM == chr]))
  ex  <- cds[cds$CHROM == chr, ]
  if (nrow(ex) == 0 || length(pos) == 0) next
  # number of SNP positions in [START, END] of each exon
  n_in <- findInterval(ex$END, pos) - findInterval(ex$START - 1, pos)
  hit_tx <- c(hit_tx, ex$TRANSCRIPT[n_in > 0])
}
hit_tx <- unique(hit_tx)
cat("Transcripts with a SNP in their coding sequence:", length(hit_tx), "\n")
if (length(hit_tx) == 0) stop("No SNPs fall in coding sequence.")


# ---- STEP 4: Read the genome (only the chromosomes we need) ---------------------
need_chr <- unique(gtf$CHROM[gtf$TRANSCRIPT %in% hit_tx])
fa  <- readLines(fasta_file)
hdr <- grep("^>", fa)
hdr_names <- sub("^chr", "", sub("^>(\\S+).*", "\\1", fa[hdr]))
hdr_end   <- c(hdr[-1] - 1, length(fa))
genome <- list()
for (chr in need_chr) {
  i <- match(chr, hdr_names)
  if (is.na(i)) { warning("Chromosome ", chr, " not found in FASTA"); next }
  genome[[chr]] <- toupper(paste(fa[(hdr[i] + 1):hdr_end[i]], collapse = ""))
}
rm(fa); invisible(gc())


# ---- STEP 5: Compare reference and population proteins ---------------------------
changes <- list(); summary_rows <- list(); fasta_out <- character(0)
ref_mismatch <- 0

for (tx in hit_tx) {
  ex <- gtf[gtf$TRANSCRIPT %in% tx, ]
  chr <- ex$CHROM[1]; strand <- ex$STRAND[1]
  if (is.null(genome[[chr]])) next

  # Genomic positions of every coding base, in transcript (5' -> 3') order
  ex  <- ex[order(ex$START), ]
  pos <- unique(unlist(mapply(seq, ex$START, ex$END, SIMPLIFY = FALSE)))
  if (strand == "-") pos <- rev(pos)

  # Skip the leading bases given by the frame of the 5'-most CDS exon
  # (non-zero only for transcripts whose start is incomplete)
  cds_ex <- ex[ex$FEATURE == "CDS", ]
  first  <- if (strand == "-") which.max(cds_ex$END) else which.min(cds_ex$START)
  phase  <- cds_ex$FRAME[first]; if (is.na(phase)) phase <- 0
  if (phase > 0) pos <- pos[-(1:phase)]

  span <- strsplit(substr(genome[[chr]], min(pos), max(pos)), "")[[1]]
  ref_bases <- span[pos - min(pos) + 1]
  if (strand == "-") ref_bases <- complement(ref_bases)
  ref_cod <- to_codons(ref_bases)
  ref_aa  <- translate_codons(ref_cod)
  ref_prot <- paste(ref_aa, collapse = "")

  gene_name <- ex$GENE_NAME[1]
  tx_fasta  <- paste0(">", tx, "|", gene_name, "|reference")
  tx_fasta  <- c(tx_fasta, sub("(\\*).*", "\\1", ref_prot))
  any_change <- FALSE

  for (pop in pops) {
    s <- snps[snps$SPECIES == pop & snps$CHROM == chr & snps$POS %in% pos, ]
    if (nrow(s) == 0) next
    idx <- match(s$POS, pos)                       # index in coding sequence
    ref_here <- toupper(s$REF); alt_here <- toupper(s$ALT)
    if (strand == "-") { ref_here <- complement(ref_here); alt_here <- complement(alt_here) }
    ref_mismatch <- ref_mismatch + sum(ref_bases[idx] != ref_here)

    alt_bases <- ref_bases
    alt_bases[idx] <- alt_here
    alt_cod <- to_codons(alt_bases)
    alt_aa  <- translate_codons(alt_cod)

    changed <- which(alt_cod != ref_cod)
    if (length(changed) == 0) next                 # SNP in a trailing partial codon
    any_change <- TRUE

    type <- ifelse(alt_aa[changed] == ref_aa[changed], "synonymous",
            ifelse(alt_aa[changed] == "*", "stop_gained",
            ifelse(ref_aa[changed] == "*", "stop_lost", "missense")))
    type[changed == 1 & ref_aa[1] == "M" & alt_aa[1] != "M"] <- "start_lost"

    # Changes downstream of a new premature stop codon would not be translated
    new_stop <- changed[type == "stop_gained"]
    after_stop <- if (length(new_stop)) changed > min(new_stop) else rep(FALSE, length(changed))

    snp_codon <- ceiling(idx / 3)
    changes[[length(changes) + 1]] <- data.frame(
      TRANSCRIPT = tx, GENE = gene_name, POPULATION = pop, CHROM = chr,
      STRAND = strand, CODON = changed,
      GENOMIC_POS = sapply(changed, function(k) paste(sort(s$POS[snp_codon == k]), collapse = ",")),
      ALT_FREQ = sapply(changed, function(k) paste(s$ALT_FREQ[snp_codon == k][order(s$POS[snp_codon == k])], collapse = ",")),
      REF_CODON = ref_cod[changed], ALT_CODON = alt_cod[changed],
      REF_AA = ref_aa[changed], ALT_AA = alt_aa[changed],
      CHANGE = paste0(ref_aa[changed], changed, alt_aa[changed]),
      TYPE = type, AFTER_NEW_STOP = after_stop, stringsAsFactors = FALSE)

    summary_rows[[length(summary_rows) + 1]] <- data.frame(
      TRANSCRIPT = tx, GENE = gene_name, POPULATION = pop,
      PROTEIN_LENGTH = sum(cumsum(ref_aa == "*") == 0),
      SNPS_IN_CDS = nrow(s),
      SYNONYMOUS = sum(type == "synonymous"),
      MISSENSE = sum(type == "missense"),
      STOP_GAINED = sum(type == "stop_gained"),
      STOP_LOST = sum(type == "stop_lost"),
      START_LOST = sum(type == "start_lost"),
      PROTEIN_CHANGED = any(type != "synonymous"),
      stringsAsFactors = FALSE)

    tx_fasta <- c(tx_fasta, paste0(">", tx, "|", gene_name, "|", pop),
                  sub("(\\*).*", "\\1", paste(alt_aa, collapse = "")))
  }
  if (any_change) fasta_out <- c(fasta_out, tx_fasta)
}


# ---- STEP 6: Write the output ----------------------------------------------------
if (length(changes) == 0) stop("SNPs fall in coding sequence but change no codons.")
changes <- do.call(rbind, changes)
summ    <- do.call(rbind, summary_rows)
write.table(changes, "protein_changes.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(summ, "protein_summary.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
writeLines(fasta_out, "proteins.fa")

for (pop in pops) {
  d <- changes[changes$POPULATION == pop, ]
  g <- summ[summ$POPULATION == pop, ]
  cat(sprintf("%-10s %5d codons changed: %d synonymous, %d missense, %d stop gained, %d stop lost, %d start lost\n",
              pop, nrow(d), sum(d$TYPE == "synonymous"), sum(d$TYPE == "missense"),
              sum(d$TYPE == "stop_gained"), sum(d$TYPE == "stop_lost"),
              sum(d$TYPE == "start_lost")))
  cat(sprintf("%-10s %5d of %d transcripts have a changed protein (%d genes)\n",
              "", sum(g$PROTEIN_CHANGED), nrow(g),
              length(unique(g$GENE[g$PROTEIN_CHANGED]))))
}
if (ref_mismatch > 0)
  warning(ref_mismatch, " SNPs had a REF base that does not match the FASTA. ",
          "Check that the FASTA and GTF are for the reference the VCF was mapped to.")
cat("Wrote protein_changes.tsv, protein_summary.tsv and proteins.fa\n")
