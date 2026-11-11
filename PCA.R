###############################################################################
# PCA of a multi-population VCF file, entirely in R (no PLINK needed)
#
# What you need:
#   1. A VCF file with all your samples (plain .vcf or compressed .vcf.gz)
#   2. R, with the ggplot2 package for the plot: install.packages("ggplot2")
#      Everything else uses functions built into R.
#   3. One text file per population (two or more), one sample name per
#      line, spelled exactly as in the VCF header, e.g. pop1.txt, pop2.txt
#
# How to run - either way works, with any number of populations:
#   (a) Edit the SETTINGS section below, then open this file in RStudio and
#       click "Source", or type in a terminal:   Rscript vcf_pca.R
#   (b) Give the files on the command line instead of editing the script:
#         Rscript vcf_pca.R my_data.vcf.gz pop1.txt pop2.txt
#         Rscript vcf_pca.R my_data.vcf.gz pop1.txt pop2.txt pop3.txt
#       The first file is the VCF; every file after it is one population.
#
# What is a PCA, briefly?
#   Each sample has a genotype at thousands of SNPs, which is far too much
#   to look at directly. A PCA summarises all of that into a few new
#   variables called principal components (PCs). PC1 is the single
#   direction that captures the most genetic variation among the samples,
#   PC2 captures the most of what is left, and so on. When we plot every
#   sample on PC1 vs PC2, genetically similar samples land close together,
#   so samples from the same population usually form a cluster.
#   The PCA itself does not know which population each sample is from: we
#   only add the colours afterwards. If the samples still cluster by
#   population, that is evidence of real genetic structure.
#
# Overview of the steps:
#   1. Read the population files
#   2. Read the VCF
#   3. Keep only simple SNPs (one letter changed, two alleles)
#   4. Turn genotypes into numbers (0, 1, 2)
#   5. Filter out unreliable or uninformative SNPs
#   6. Thin SNPs so nearby, linked SNPs are not over-counted
#   7. Fill in the few remaining missing genotypes
#   8. Run the PCA
#   9. Plot and save the results
###############################################################################

library(ggplot2)

# ---- SETTINGS: change these to match your files ----------------------------
vcf_file   <- "my_data.vcf.gz"            # your VCF
pop_files  <- c("pop1.txt", "pop2.txt")   # list as many population files as
                                          # you have, e.g. add "pop3.txt"
out_prefix <- "pca"                       # names of output files

max_missing <- 0.1    # drop SNPs missing in more than 10% of samples
min_maf     <- 0.05   # drop SNPs whose rarer allele is below 5% frequency
thin_bp     <- 100    # keep at most one SNP per 100 bp (0 = no thinning);
                      # see STEP 6 for why this suits Drosophila

# If files were given on the command line, use those instead of the
# settings above. commandArgs(trailingOnly = TRUE) returns whatever was
# typed after the script name.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1) vcf_file  <- args[1]
if (length(args) >= 2) pop_files <- args[-1]   # everything after the VCF


###############################################################################
# STEP 1: Read the population files
###############################################################################
# For each file, read the sample names and use the file name (without
# ".txt") as the population name, e.g. pop1.txt -> "pop1".
# Tip: name your files after the populations (Kenya.txt, France.txt, ...)
# and those names will appear in the plot legend.
# The loop below runs once per file, so it works the same for 2, 3 or
# more populations; the plot picks a colour for each automatically.

# Basic checks, so mistakes give a clear message instead of a strange error
if (length(pop_files) < 2) stop("Please give at least two population files.")
for (f in pop_files) {
  if (!file.exists(f)) stop("Population file not found: ", f)
}

pop_list <- list()
for (f in pop_files) {
  names <- trimws(readLines(f))     # read names, remove stray spaces
  names <- names[names != ""]       # drop empty lines
  pop_list[[f]] <- data.frame(sample = names,
                              population = sub("\\.txt$", "", basename(f)))
}
pops <- do.call(rbind, pop_list)    # stack them into one table

# A sample listed in two population files would be ambiguous
dups <- unique(pops$sample[duplicated(pops$sample)])
if (length(dups) > 0) {
  stop("These samples are listed in more than one population file: ",
       paste(dups, collapse = ", "))
}
cat("Populations:", length(pop_files), " Samples:", nrow(pops), "\n")


###############################################################################
# STEP 2: Read the VCF
###############################################################################
# A VCF starts with many header lines beginning with "##" (information
# about the file), then one line beginning with "#CHROM" that names the
# columns, then one line per variant.
# The first 9 columns describe the variant:
#   CHROM POS ID REF ALT QUAL FILTER INFO FORMAT
# and every column after that is one sample's genotype, e.g. "0/1:12:..."
#
# First we find which line is the "#CHROM" line, so we know how many
# header lines to skip and what the sample names are.
con <- file(vcf_file, "r")          # file() reads .gz files automatically
n_header <- 0
repeat {
  line <- readLines(con, n = 1)
  n_header <- n_header + 1
  if (startsWith(line, "#CHROM")) break
}
close(con)
col_names <- strsplit(line, "\t")[[1]]
col_names[1] <- "CHROM"             # remove the "#" from "#CHROM"

# Now read the variant lines as a table. colClasses = "character" reads
# everything as text, which is faster and keeps genotypes like "0/1" intact.
vcf <- read.table(vcf_file, skip = n_header, sep = "\t",
                  col.names = col_names, colClasses = "character",
                  comment.char = "", check.names = FALSE, quote = "")
cat("Variants in VCF:", nrow(vcf), "\n")

# Which samples are in both the VCF and the population files?
vcf_samples <- col_names[10:length(col_names)]
missing_from_vcf <- setdiff(pops$sample, vcf_samples)
if (length(missing_from_vcf) > 0) {
  warning("These samples are in a population file but not in the VCF: ",
          paste(missing_from_vcf, collapse = ", "))
}
pops <- pops[pops$sample %in% vcf_samples, ]
cat("Samples used in the PCA:", nrow(pops), "\n")


###############################################################################
# STEP 3: Keep only simple SNPs
###############################################################################
# REF is the reference letter, ALT the alternative letter(s).
#   nchar(...) == 1   one letter each, so it is a SNP and not an insertion
#                     or deletion (e.g. REF "A", ALT "ATTG" is an insertion)
#   ALT has no comma  only one alternative allele, i.e. "biallelic"
#                     (e.g. ALT "G,T" would mean three alleles at this site)
is_snp <- nchar(vcf$REF) == 1 & nchar(vcf$ALT) == 1 & vcf$ALT != "."
vcf <- vcf[is_snp, ]
cat("Biallelic SNPs:", nrow(vcf), "\n")


###############################################################################
# STEP 4: Turn genotypes into numbers
###############################################################################
# Each genotype entry looks like "0/1:15:99:..." - the part before the
# first ":" is the genotype (GT); the rest (read depth etc.) we don't need.
# We count how many copies of the ALT allele each sample has:
#   0/0 -> 0   (two reference alleles)
#   0/1 -> 1   (one of each, heterozygous)
#   1/1 -> 2   (two alternative alleles)
#   ./. -> NA  (missing, no genotype could be called)
# "|" instead of "/" (e.g. 0|1) means the genotype is phased; for a PCA
# that makes no difference, so we treat them the same.
gt_text <- as.matrix(vcf[, pops$sample])                 # sample columns only
gt_text <- sub(":.*", "", gt_text)                       # keep the GT part
gt_text <- gsub("|", "/", gt_text, fixed = TRUE)         # 0|1 -> 0/1

dosage_lookup <- c("0/0" = 0, "0/1" = 1, "1/0" = 1, "1/1" = 2,
                   "0" = 0, "1" = 2)   # "0"/"1": haploid calls
geno <- matrix(dosage_lookup[gt_text], nrow = nrow(gt_text))
# Anything not in the lookup table (./., ., etc.) automatically becomes NA.

# Rows = SNPs, columns = samples. Give them names so we can track them.
rownames(geno) <- paste(vcf$CHROM, vcf$POS, sep = ":")
colnames(geno) <- pops$sample


###############################################################################
# STEP 5: Filter SNPs
###############################################################################
# (a) Missing data: the fraction of samples with NA at each SNP.
#     rowMeans(is.na(geno)) gives that fraction for every row (SNP).
missing_frac <- rowMeans(is.na(geno))

# (b) Minor allele frequency (MAF). The ALT allele frequency is the average
#     dosage divided by 2 (each sample carries two copies). The "minor"
#     allele is whichever of REF/ALT is rarer, so MAF = min(p, 1 - p).
#     Rare alleles add noise (and are often sequencing errors), and SNPs
#     where everyone is identical carry no information for a PCA.
alt_freq <- rowMeans(geno, na.rm = TRUE) / 2
maf <- pmin(alt_freq, 1 - alt_freq)

keep <- missing_frac <= max_missing & !is.na(maf) & maf >= min_maf
geno <- geno[keep, ]
vcf  <- vcf[keep, ]
cat("SNPs after missing-data and MAF filters:", nrow(geno), "\n")


###############################################################################
# STEP 6: Thin the SNPs
###############################################################################
# SNPs close together on a chromosome tend to be inherited together
# (linkage disequilibrium, LD), so they carry almost the same
# information. If a region has lots of such SNPs it can dominate the PCA.
# A simple fix is "thinning": walk along each chromosome and keep a SNP
# only if it is at least thin_bp base pairs from the previous SNP we kept.
#
# How far apart is far enough depends on the species. In Drosophila,
# recombination is frequent and populations are large, so LD usually
# breaks down within a few hundred base pairs (much faster than in
# humans, where LD can stretch for tens of thousands of bp). Thinning to
# one SNP per 100 bp is therefore plenty; heavier thinning would mostly
# throw away useful, independent SNPs. Set thin_bp <- 0 to skip thinning.
# (PLINK's "LD pruning" does the same job by measuring the correlation
# between SNPs; thinning by distance is the simple version.)
if (thin_bp > 0) {
  pos <- as.numeric(vcf$POS)
  keep <- logical(nrow(vcf))
  last_chrom <- ""
  last_pos <- -Inf
  for (i in seq_len(nrow(vcf))) {           # assumes VCF is sorted by position
    if (vcf$CHROM[i] != last_chrom || pos[i] - last_pos >= thin_bp) {
      keep[i] <- TRUE
      last_chrom <- vcf$CHROM[i]
      last_pos <- pos[i]
    }
  }
  geno <- geno[keep, ]
  cat("SNPs after thinning to one per", thin_bp, "bp:", nrow(geno), "\n")
}


###############################################################################
# STEP 7: Fill in the remaining missing genotypes
###############################################################################
# A PCA cannot handle missing values. Because we already removed SNPs with
# lots of missing data, only a few NAs are left. We replace each with the
# average dosage at that SNP ("mean imputation"): this places the sample
# in the middle for that SNP, so it doesn't push the sample in any
# direction. This is standard practice for genetic PCA.
for (i in seq_len(nrow(geno))) {
  row_mean <- mean(geno[i, ], na.rm = TRUE)
  geno[i, is.na(geno[i, ])] <- row_mean
}


###############################################################################
# STEP 8: Run the PCA
###############################################################################
# prcomp() is R's built-in PCA function. It expects samples as rows and
# variables (SNPs) as columns, so we transpose the matrix with t().
#   center = TRUE   subtract each SNP's average first (required for PCA)
#   scale. = FALSE  don't rescale SNPs; all SNPs are already on the same
#                   0-2 scale
pca <- prcomp(t(geno), center = TRUE, scale. = FALSE)

# How much of the total variation does each PC explain?
# pca$sdev holds the standard deviation along each PC; squaring gives the
# variance, and dividing by the total gives the proportion.
pct <- round(100 * pca$sdev^2 / sum(pca$sdev^2), 1)
cat("Variation explained (%): PC1 =", pct[1], " PC2 =", pct[2],
    " PC3 =", pct[3], "\n")

# pca$x holds each sample's position (score) on each PC.
n_pcs <- min(10, ncol(pca$x))
results <- data.frame(sample = rownames(pca$x),
                      population = pops$population,
                      pca$x[, 1:n_pcs])


###############################################################################
# STEP 9: Plot and save
###############################################################################
# Each point is one sample, placed by its PC1 and PC2 values and coloured
# by population. Axis labels show how much variation each PC explains.
p <- ggplot(results, aes(x = PC1, y = PC2, colour = population)) +
  geom_point(size = 3, alpha = 0.8) +
  labs(x = paste0("PC1 (", pct[1], "% of variation)"),
       y = paste0("PC2 (", pct[2], "% of variation)"),
       colour = "Population") +
  theme_bw()

ggsave(paste0(out_prefix, "_plot.pdf"), p, width = 6, height = 5)
ggsave(paste0(out_prefix, "_plot.png"), p, width = 6, height = 5, dpi = 300)

# Save each sample's PC values (useful for plotting PC1 vs PC3, etc.)
write.table(results, paste0(out_prefix, "_results.tsv"),
            sep = "\t", quote = FALSE, row.names = FALSE)

cat("Done. Wrote", paste0(out_prefix, "_plot.pdf/.png"), "and",
    paste0(out_prefix, "_results.tsv"), "\n")
