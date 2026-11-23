###############################################################################
# Gene sequences with high-frequency SNPs, for each species
#
# For every gene in a BED file (or in dxy_genes.tsv), take the reference
# sequence from the genome FASTA and, separately for each species, replace
# the reference base with the alternative base at every SNP where the
# alternative allele frequency in that species is >= a threshold you choose.
#
# Example: with threshold 0.7, a SNP where 80% of the D. simulans allele
# copies carry the ALT base gets the ALT base in the simulans sequence;
# a SNP at 50% keeps the reference base.
#
# ---- Allele frequencies WITH allele letters ---------------------------------
# The .frq files from species_allele_freqs.sh were made with --freq2, which
# leaves out the allele letters, so they can't say which base to put in.
# Make new ones with --freq instead (same command otherwise), e.g.:
#
#   vcftools --gzvcf my_data.vcf.gz --keep mel.txt \
#       --remove-indels --min-alleles 2 --max-alleles 2 \
#       --freq --out mel_alleles
#   vcftools --gzvcf my_data.vcf.gz --keep sim.txt \
#       --remove-indels --min-alleles 2 --max-alleles 2 \
#       --freq --out sim_alleles
#
# Each row then looks like:  2L  10234  2  20  A:0.25  G:0.75
# (the first allele is the reference base, the second the alternative).
#
# ---- Usage ------------------------------------------------------------------
#   Rscript gene_sequences.R genome.fa regions threshold sp1.frq [sp2.frq ...]
#   e.g.
#   Rscript gene_sequences.R dmel.fasta genes.bed 0.7 mel_alleles.frq sim_alleles.frq
#   Rscript gene_sequences.R dmel.fasta dxy_genes.tsv 0.7 mel_alleles.frq sim_alleles.frq
#
#   regions: a BED file (chrom, start, end, name, [score], [strand]) or the
#            dxy_genes.tsv written by dxy_genes.R. With dxy_genes.tsv you can
#            keep only the outlier genes (see outliers_only below).
#
# Output:
#   gene_sequences.fa     one sequence per gene per species (plus the
#                         reference if include_reference = TRUE)
#   substituted_snps.tsv  every SNP that was put into a sequence
###############################################################################

# ---- Settings ----------------------------------------------------------------
args       <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4)
  stop("Usage: Rscript gene_sequences.R genome.fa regions threshold sp1.frq [sp2.frq ...]")
fasta_file <- args[1]
region_file <- args[2]
threshold  <- as.numeric(args[3])
frq_files  <- args[4:length(args)]

min_chr           <- 4      # ignore SNPs with fewer called allele copies
outliers_only     <- TRUE   # with dxy_genes.tsv: only genes with outlier = TRUE
include_reference <- TRUE   # also write the unchanged reference sequence
revcomp_minus     <- TRUE   # reverse-complement genes on the "-" strand
                            # (needs a strand column in the BED file)

# Species names come from the file names: "mel_alleles.frq" -> "mel"
species <- sub("(_alleles|_freq)?\\.frq$", "", basename(frq_files))


# ---- STEP 1: Read the regions -----------------------------------------------
first <- readLines(region_file, n = 1)
if (grepl("^CHROM\tSTART\tEND\tGENE", first)) {
  # dxy_genes.tsv from dxy_genes.R (START is 0-based, like BED)
  reg <- read.delim(region_file, stringsAsFactors = FALSE)
  if (outliers_only) reg <- reg[reg$outlier %in% c(TRUE, "TRUE"), ]
  genes <- data.frame(CHROM = reg$CHROM, START = reg$START, END = reg$END,
                      GENE = reg$GENE, STRAND = "+", stringsAsFactors = FALSE)
} else {
  bed <- read.table(region_file, sep = "\t", header = FALSE, quote = "",
                    comment.char = "", stringsAsFactors = FALSE, fill = TRUE)
  bed <- bed[!grepl("^(#|track|browser)", bed[[1]]), ]
  genes <- data.frame(CHROM = bed[[1]], START = as.numeric(bed[[2]]),
                      END = as.numeric(bed[[3]]), stringsAsFactors = FALSE)
  genes$GENE   <- if (ncol(bed) >= 4) bed[[4]] else
    paste0(genes$CHROM, ":", genes$START + 1, "-", genes$END)
  genes$STRAND <- if (ncol(bed) >= 6) bed[[6]] else "+"
}
genes$CHROM <- sub("^chr", "", genes$CHROM)
if (!revcomp_minus) genes$STRAND <- "+"
cat("Genes to extract:", nrow(genes), "\n")
if (nrow(genes) == 0) stop("No genes to extract.")


# ---- STEP 2: Read the genome (only the chromosomes we need) -----------------
fa <- readLines(fasta_file)
hdr <- grep("^>", fa)
# Chromosome name = first word of the header, without "chr"
hdr_names <- sub("^chr", "", sub("^>(\\S+).*", "\\1", fa[hdr]))
hdr_end   <- c(hdr[-1] - 1, length(fa))

genome <- list()
for (chr in unique(genes$CHROM)) {
  i <- match(chr, hdr_names)
  if (is.na(i)) { warning("Chromosome ", chr, " not found in FASTA"); next }
  genome[[chr]] <- toupper(paste(fa[(hdr[i] + 1):hdr_end[i]], collapse = ""))
}
rm(fa); invisible(gc())


# ---- STEP 3: Read the allele frequency files ---------------------------------
# Columns: CHROM POS N_ALLELES N_CHR REF:freq ALT:freq
read_frq_alleles <- function(f) {
  d <- read.table(f, skip = 1, sep = "\t", fill = TRUE,
                  colClasses = "character", col.names = paste0("V", 1:6))
  out <- data.frame(CHROM = sub("^chr", "", d$V1),
                    POS   = as.numeric(d$V2),
                    N_CHR = as.numeric(d$V4),
                    REF   = sub(":.*", "", d$V5),
                    ALT   = sub(":.*", "", d$V6),
                    ALT_FREQ = suppressWarnings(as.numeric(sub(".*:", "", d$V6))),
                    stringsAsFactors = FALSE)
  if (!any(grepl(":", d$V5)))
    stop(f, " has no allele letters: make it with vcftools --freq, not --freq2")
  out[!is.na(out$ALT_FREQ) & out$N_CHR >= min_chr, ]
}
frq <- lapply(frq_files, read_frq_alleles)
names(frq) <- species


# ---- STEP 4: Build the sequences ----------------------------------------------
revcomp <- function(s) {
  paste(rev(strsplit(chartr("ACGTRYKMBDHVN", "TGCAYRMKVHDBN", s), "")[[1]]),
        collapse = "")
}

fasta_out <- character(0)
snp_table <- list()
ref_mismatch <- 0

for (k in seq_len(nrow(genes))) {
  g <- genes[k, ]
  if (is.null(genome[[g$CHROM]])) next
  ref_seq <- substr(genome[[g$CHROM]], g$START + 1, g$END)
  coord   <- paste0(g$CHROM, ":", g$START + 1, "-", g$END, "(", g$STRAND, ")")
  orient  <- function(s) if (g$STRAND == "-") revcomp(s) else s

  if (include_reference)
    fasta_out <- c(fasta_out, paste0(">", g$GENE, "|reference|", coord),
                   orient(ref_seq))

  for (sp in species) {
    s <- frq[[sp]]
    s <- s[s$CHROM == g$CHROM & s$POS > g$START & s$POS <= g$END &
           s$ALT_FREQ >= threshold, ]
    bases <- strsplit(ref_seq, "")[[1]]
    if (nrow(s) > 0) {
      idx <- s$POS - g$START                  # position within the gene
      ref_mismatch <- ref_mismatch + sum(bases[idx] != toupper(s$REF))
      bases[idx] <- s$ALT
      snp_table[[length(snp_table) + 1]] <- data.frame(
        GENE = g$GENE, SPECIES = sp, CHROM = g$CHROM, POS = s$POS,
        REF = s$REF, ALT = s$ALT, ALT_FREQ = s$ALT_FREQ, N_CHR = s$N_CHR,
        stringsAsFactors = FALSE)
    }
    fasta_out <- c(fasta_out,
                   paste0(">", g$GENE, "|", sp, "|", coord, "|",
                          nrow(s), "_SNPs_freq>=", threshold),
                   orient(paste(bases, collapse = "")))
  }
}


# ---- STEP 5: Write the output --------------------------------------------------
writeLines(fasta_out, "gene_sequences.fa")
snps_out <- if (length(snp_table)) do.call(rbind, snp_table) else
  data.frame(GENE = character(), SPECIES = character(), CHROM = character(),
             POS = numeric(), REF = character(), ALT = character(),
             ALT_FREQ = numeric(), N_CHR = numeric())
write.table(snps_out, "substituted_snps.tsv", sep = "\t", quote = FALSE,
            row.names = FALSE)

for (sp in species)
  cat(sprintf("%-10s %6d SNPs substituted (ALT frequency >= %g)\n",
              sp, sum(snps_out$SPECIES == sp), threshold))
if (ref_mismatch > 0)
  warning(ref_mismatch, " SNPs had a REF base that does not match the FASTA. ",
          "Check that the FASTA is the reference the VCF was mapped to.")
cat("Wrote gene_sequences.fa and substituted_snps.tsv\n")
