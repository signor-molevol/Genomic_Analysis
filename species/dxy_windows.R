###############################################################################
# Option 2, step 2: approximate dxy (absolute divergence) in windows
#
# dxy = the average number of differences per site between a sequence
# from species 1 and a sequence from species 2. dxy = 0.05 means that two
# randomly chosen sequences, one from each species, differ at 5% of sites.
#
# At one SNP, with alternative-allele frequencies p1 (species 1) and
# p2 (species 2), the chance that a random sequence from each species
# carries different alleles is:
#
#     p1 * (1 - p2)  +  p2 * (1 - p1)
#     (species 1 has ALT,   (species 1 has REF,
#      species 2 has REF)    species 2 has ALT)
#
#   Fixed difference (p1 = 1, p2 = 0):          1 * 1 + 0 * 0 = 1
#   Same allele fixed in both (p1 = p2 = 1):    1 * 0 + 1 * 0 = 0
#   Both at 50% (p1 = p2 = 0.5):          0.5*0.5 + 0.5*0.5 = 0.5
#
# Unlike counting fixed differences (Option 1), this also counts sites
# where the species differ only partly.
#
# For each window we add up this value over all SNPs and divide by the
# window length. The "messy" assumption: every position in the window
# that is not in the SNP list was sequenced and is identical in the two
# species. Regions with missing data (e.g. where reads did not map) will
# therefore look less divergent than they really are.
#
# Usage:
#   Rscript dxy_windows.R mel_freq.frq sim_freq.frq [window_bp] [min_snps]
#   e.g.
#   Rscript dxy_windows.R mel_freq.frq sim_freq.frq 10000 20
#
# Input: the two .frq files from species_allele_freqs.sh
# Requires: ggplot2 (for the plot)
###############################################################################

library(ggplot2)

# ---- Settings ----------------------------------------------------------------
args      <- commandArgs(trailingOnly = TRUE)
frq1_file <- args[1]
frq2_file <- args[2]
window_bp <- if (length(args) >= 3) as.numeric(args[3]) else 10000  # 10 kb
min_snps  <- if (length(args) >= 4) as.numeric(args[4]) else 20
min_chr   <- 4          # need at least 4 called allele copies per species
top       <- 0.01       # flag the top 1% of windows
autosomes <- c("2L", "2R", "3L", "3R")
x_chrom   <- "X"
chrom_order <- c(x_chrom, autosomes)


# ---- STEP 1: Read the allele frequency files ---------------------------------
# The header line of a .frq file has fewer column names than there are
# columns, so we skip it and name the columns ourselves.
read_frq <- function(f) {
  d <- read.table(f, skip = 1, sep = "\t", fill = TRUE,
                  colClasses = c("character", "numeric", "numeric",
                                 "numeric", "numeric", "numeric"))
  colnames(d) <- c("CHROM", "POS", "N_ALLELES", "N_CHR", "FREQ_REF", "FREQ_ALT")
  d[, c("CHROM", "POS", "N_CHR", "FREQ_ALT")]
}
sp1 <- read_frq(frq1_file)
sp2 <- read_frq(frq2_file)

# Put the two species side by side: one row per SNP.
# suffixes add "_1" and "_2" to the column names of each species.
snps <- merge(sp1, sp2, by = c("CHROM", "POS"), suffixes = c("_1", "_2"))

# Keep the main arms, and SNPs genotyped in enough flies of both species.
snps <- snps[snps$CHROM %in% chrom_order &
             snps$N_CHR_1 >= min_chr & snps$N_CHR_2 >= min_chr &
             !is.na(snps$FREQ_ALT_1) & !is.na(snps$FREQ_ALT_2), ]
cat("SNPs used:", nrow(snps), "\n")


# ---- STEP 2: dxy at each SNP --------------------------------------------------
p1 <- snps$FREQ_ALT_1
p2 <- snps$FREQ_ALT_2
snps$dxy_site <- p1 * (1 - p2) + p2 * (1 - p1)


# ---- STEP 3: Sum per window and divide by window length ---------------------
snps$WIN_START <- ((snps$POS - 1) %/% window_bp) * window_bp + 1

sum_dxy <- aggregate(dxy_site ~ CHROM + WIN_START, data = snps, FUN = sum)
n_snps  <- aggregate(dxy_site ~ CHROM + WIN_START, data = snps, FUN = length)
win <- merge(sum_dxy, n_snps, by = c("CHROM", "WIN_START"))
colnames(win) <- c("CHROM", "WIN_START", "SUM_DXY", "N_SNPS")
win$WIN_END <- win$WIN_START + window_bp - 1
win$DXY <- win$SUM_DXY / window_bp            # differences per site

# Windows with very few SNPs probably have little usable data; drop them.
win <- win[win$N_SNPS >= min_snps, ]


# ---- STEP 4: Rank windows, X and autosomes separately ----------------------
# Empirical p-value = fraction of windows in the same group with dxy as
# high or higher. p = 0.01 means "top 1% of its group".
win$GROUP <- ifelse(win$CHROM == x_chrom, "X", "autosomes")
win$emp_p <- NA
for (grp in c("X", "autosomes")) {
  idx <- win$GROUP == grp
  win$emp_p[idx] <- rank(-win$DXY[idx], ties.method = "max") / sum(idx)
}
win$outlier <- win$emp_p <= top

win <- win[order(match(win$CHROM, chrom_order), win$WIN_START),
           c("CHROM", "WIN_START", "WIN_END", "N_SNPS", "DXY",
             "GROUP", "emp_p", "outlier")]
write.table(win, "dxy_windows.tsv", sep = "\t", quote = FALSE, row.names = FALSE)


# ---- STEP 5: Plot along the genome ------------------------------------------
win$CHROM <- factor(win$CHROM, levels = chrom_order)
p <- ggplot(win, aes(x = WIN_START / 1e6, y = DXY, colour = outlier)) +
  geom_point(size = 0.6) +
  scale_colour_manual(values = c("FALSE" = "grey50", "TRUE" = "firebrick"),
                      labels = c("other windows", paste0("top ", 100 * top, "%")),
                      name = NULL) +
  facet_grid(. ~ CHROM, scales = "free_x", space = "free_x") +
  labs(x = "Position (Mb)", y = "dxy (differences per site)",
       title = paste0("Approximate dxy in ", window_bp / 1000, " kb windows")) +
  theme_bw() +
  theme(legend.position = "bottom", panel.spacing.x = unit(0.1, "lines"))
ggsave("dxy_plot.png", p, width = 11, height = 4, dpi = 300)
ggsave("dxy_plot.pdf", p, width = 11, height = 4)


# ---- Summary -------------------------------------------------------------------
for (grp in c("X", "autosomes")) {
  g <- win[win$GROUP == grp, ]
  cat(sprintf("%-9s %6d windows | median dxy %.4f | top %g%%: dxy >= %.4f\n",
              grp, nrow(g), median(g$DXY), 100 * top, min(g$DXY[g$outlier])))
}
cat("Wrote dxy_windows.tsv and dxy_plot.png/.pdf\n")
