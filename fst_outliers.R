###############################################################################
# Windows of elevated FST, ranked separately for the X and the autosomes
#
# Input: either vcftools FST output
#   - per-site  (.weir.fst: CHROM POS WEIR_AND_COCKERHAM_FST)
#       SNPs are grouped into non-overlapping windows of window_bp and
#       FST is averaged within each window
#   - windowed  (.windowed.weir.fst: CHROM BIN_START BIN_END ... WEIGHTED_FST)
#       the vcftools windows are used as they are
#
# Usage:
#   Rscript fst_outliers_windows.R fst_file [window_bp] [min_snps]
#   e.g.
#   Rscript fst_outliers_windows.R fst_per_site_weir.fst 1000 10
#   (window_bp is ignored for an already-windowed file)
#
# Empirical p-value = fraction of windows in the same group (X or
# autosomes) with mean FST equal to or higher than this window.
# p = 0.01 means "in the top 1% for that group". This ranks windows;
# it is not a formal test.
#
# Why rank the X separately? The X has a smaller effective population
# size than the autosomes (3/4 as many copies) and is hemizygous in males,
# so drift and selection act on it more strongly and it typically shows
# higher FST overall. Ranking everything together would mostly flag the X.
###############################################################################

args      <- commandArgs(trailingOnly = TRUE)
fst_file  <- args[1]
window_bp <- if (length(args) >= 2) as.numeric(args[2]) else 1000
min_snps  <- if (length(args) >= 3) as.numeric(args[3]) else 10
top       <- 0.01                                     # outlier cutoff (top 1%)
autosomes <- c("2L", "2R", "3L", "3R")
x_chrom   <- "X"
out_file  <- "fst_windows_outliers.tsv"

fst <- read.table(fst_file, header = TRUE, sep = "\t",
                  colClasses = c(CHROM = "character"))
fst <- fst[fst$CHROM %in% c(x_chrom, autosomes), ]

# ---- Build the window table ------------------------------------------------
if ("BIN_START" %in% colnames(fst)) {
  # Already windowed by vcftools
  win <- data.frame(CHROM = fst$CHROM, WIN_START = fst$BIN_START,
                    WIN_END = fst$BIN_END, N_SNPS = fst$N_VARIANTS,
                    FST = fst$WEIGHTED_FST)
  cat("Windowed vcftools file: using its", nrow(win), "windows\n")
} else {
  # Per-site: average FST in non-overlapping windows
  colnames(fst)[3] <- "FST"
  fst <- fst[!is.na(fst$FST), ]
  fst$WIN_START <- ((fst$POS - 1) %/% window_bp) * window_bp + 1
  key <- paste(fst$CHROM, fst$WIN_START, sep = ":")
  win <- data.frame(
    CHROM      = tapply(fst$CHROM, key, `[`, 1),
    WIN_START  = tapply(fst$WIN_START, key, `[`, 1),
    N_SNPS     = tapply(fst$FST, key, length),
    FST        = tapply(fst$FST, key, mean),
    FRAC_FIXED = tapply(fst$FST >= 1, key, mean)   # share of SNPs with FST = 1
  )
  win$WIN_END <- win$WIN_START + window_bp - 1
  cat("Per-site file: averaged", nrow(fst), "SNPs into", window_bp, "bp windows\n")
}

win <- win[!is.na(win$FST) & win$N_SNPS >= min_snps, ]

# ---- Rank X and autosomes separately ---------------------------------------
win$GROUP <- ifelse(win$CHROM == x_chrom, "X", "autosomes")
win$emp_p <- NA
for (grp in c("X", "autosomes")) {
  idx <- win$GROUP == grp
  win$emp_p[idx] <- rank(-win$FST[idx], ties.method = "max") / sum(idx)
}
win$outlier <- win$emp_p <= top

# ---- Save and summarise ----------------------------------------------------
chrom_order <- c(x_chrom, autosomes)
win <- win[order(match(win$CHROM, chrom_order), win$WIN_START), ]
cols <- intersect(c("CHROM", "WIN_START", "WIN_END", "N_SNPS", "FST",
                    "FRAC_FIXED", "GROUP", "emp_p", "outlier"), colnames(win))
write.table(win[, cols], out_file, sep = "\t", quote = FALSE, row.names = FALSE)

for (grp in c("X", "autosomes")) {
  g <- win[win$GROUP == grp, ]
  cat(sprintf("%-9s windows: %6d | median FST %.3f | top %g%%: %d windows, FST >= %.3f\n",
              grp, nrow(g), median(g$FST), 100 * top, sum(g$outlier),
              min(g$FST[g$outlier])))
}
cat("Outliers per arm:\n")
print(table(factor(win$CHROM[win$outlier], levels = chrom_order)))
cat("Wrote", out_file, "\n")
