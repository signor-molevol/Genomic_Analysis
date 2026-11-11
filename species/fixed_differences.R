###############################################################################
# Option 1: Fixed differences per kb between two species
#
# A FIXED DIFFERENCE is a site where every sample of species 1 has one base
# and every sample of species 2 has a different base. At such a site the
# per-site FST from vcftools is exactly 1, so we can find fixed differences
# simply by looking for FST = 1 in the per-site FST file.
#
# For each window along the genome we count the fixed differences and
# divide by the window length (in kb). Windows with many fixed
# differences per kb are the regions where the two species have
# diverged the most.
#
# Usage:
#   Rscript fixed_differences.R fst_per_site.weir.fst [window_bp] [min_snps]
#   e.g.
#   Rscript fixed_differences.R fst_per_site_weir.fst 10000 20
#
# Input: the per-site FST file from vcftools (--weir-fst-pop without a
#        window size): CHROM  POS  WEIR_AND_COCKERHAM_FST
# Requires: ggplot2 (for the plot)
###############################################################################

library(ggplot2)

# ---- Settings ----------------------------------------------------------------
args      <- commandArgs(trailingOnly = TRUE)
fst_file  <- args[1]
window_bp <- if (length(args) >= 2) as.numeric(args[2]) else 10000  # 10 kb
min_snps  <- if (length(args) >= 3) as.numeric(args[3]) else 20
top       <- 0.01                              # flag the top 1% of windows
autosomes <- c("2L", "2R", "3L", "3R")
x_chrom   <- "X"
chrom_order <- c(x_chrom, autosomes)


# ---- STEP 1: Read the per-site FST file -------------------------------------
fst <- read.table(fst_file, header = TRUE, sep = "\t",
                  colClasses = c("character", "numeric", "numeric"))
colnames(fst) <- c("CHROM", "POS", "FST")

# Keep the main chromosome arms and drop sites where FST could not be
# calculated (NA / nan).
fst <- fst[fst$CHROM %in% chrom_order & !is.na(fst$FST), ]

# TRUE/FALSE: is this site a fixed difference?
fst$fixed <- fst$FST >= 1
cat("SNPs:", nrow(fst), "  fixed differences:", sum(fst$fixed), "\n")


# ---- STEP 2: Put every SNP into a window ------------------------------------
# %/% is whole-number division, so with 10,000 bp windows positions
# 1-10,000 go to window start 1, 10,001-20,000 to window start 10,001, etc.
fst$WIN_START <- ((fst$POS - 1) %/% window_bp) * window_bp + 1


# ---- STEP 3: Count per window -----------------------------------------------
# aggregate() splits the table by chromosome and window, then applies a
# function to each piece: length() counts SNPs, sum() of TRUE/FALSE
# counts the fixed differences (TRUE counts as 1).
n_snps  <- aggregate(FST ~ CHROM + WIN_START, data = fst, FUN = length)
n_fixed <- aggregate(fixed ~ CHROM + WIN_START, data = fst, FUN = sum)
win <- merge(n_snps, n_fixed)
colnames(win) <- c("CHROM", "WIN_START", "N_SNPS", "N_FIXED")
win$WIN_END <- win$WIN_START + window_bp - 1

# Fixed differences per kb of sequence
win$FIXED_PER_KB <- win$N_FIXED / (window_bp / 1000)

# Windows with very few SNPs often have little usable data (e.g. reads
# didn't map there), so their counts are unreliable. Drop them.
win <- win[win$N_SNPS >= min_snps, ]


# ---- STEP 4: Rank windows, X and autosomes separately ----------------------
# The X usually diverges differently from the autosomes, so each window is
# compared only with windows of its own group.
# Empirical p-value = fraction of windows in the group with as many or more
# fixed differences per kb. p = 0.01 means "top 1% of its group".
win$GROUP <- ifelse(win$CHROM == x_chrom, "X", "autosomes")
win$emp_p <- NA
for (grp in c("X", "autosomes")) {
  idx <- win$GROUP == grp
  win$emp_p[idx] <- rank(-win$FIXED_PER_KB[idx], ties.method = "max") / sum(idx)
}
win$outlier <- win$emp_p <= top

win <- win[order(match(win$CHROM, chrom_order), win$WIN_START), ]
write.table(win, "fixed_differences_windows.tsv", sep = "\t",
            quote = FALSE, row.names = FALSE)


# ---- STEP 5: Plot along the genome ------------------------------------------
win$CHROM <- factor(win$CHROM, levels = chrom_order)
p <- ggplot(win, aes(x = WIN_START / 1e6, y = FIXED_PER_KB, colour = outlier)) +
  geom_point(size = 0.6) +
  scale_colour_manual(values = c("FALSE" = "grey50", "TRUE" = "firebrick"),
                      labels = c("other windows", paste0("top ", 100 * top, "%")),
                      name = NULL) +
  facet_grid(. ~ CHROM, scales = "free_x", space = "free_x") +
  labs(x = "Position (Mb)", y = "Fixed differences per kb",
       title = paste0("Fixed differences in ", window_bp / 1000, " kb windows")) +
  theme_bw() +
  theme(legend.position = "bottom", panel.spacing.x = unit(0.1, "lines"))
ggsave("fixed_differences_plot.png", p, width = 11, height = 4, dpi = 300)
ggsave("fixed_differences_plot.pdf", p, width = 11, height = 4)


# ---- Summary -------------------------------------------------------------------
for (grp in c("X", "autosomes")) {
  g <- win[win$GROUP == grp, ]
  cat(sprintf("%-9s %6d windows | median %.1f fixed/kb | top %g%%: >= %.1f fixed/kb\n",
              grp, nrow(g), median(g$FIXED_PER_KB), 100 * top,
              min(g$FIXED_PER_KB[g$outlier])))
}
cat("Wrote fixed_differences_windows.tsv and fixed_differences_plot.png/.pdf\n")
