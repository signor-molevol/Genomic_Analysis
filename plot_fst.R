###############################################################################
# Plot FST around each gene in a BED file
#
# For every region in the BED file (chr, start, end, gene), take the region
# plus 1,000 bp on each side, find the FST values that fall in it, and make
# one plot per gene.
#
# Works with either vcftools FST output:
#   - windowed (.windowed.weir.fst: CHROM BIN_START BIN_END ... WEIGHTED_FST)
#     each window that overlaps the region is drawn as a horizontal line
#     spanning the window, at the height of its FST
#   - per-site (.weir.fst: CHROM POS WEIR_AND_COCKERHAM_FST)
#     each SNP in the region is drawn as a point
#
# Usage:
#   Rscript plot_fst_regions.R genes.bed fst_file [flank_bp] [output_folder]
#   e.g.
#   Rscript plot_fst_regions.R genes.bed fst_windows.windowed.weir.fst 1000 fst_gene_plots
#
# Requires: ggplot2
###############################################################################

library(ggplot2)

args    <- commandArgs(trailingOnly = TRUE)
bed_file <- args[1]
fst_file <- args[2]
flank    <- if (length(args) >= 3) as.numeric(args[3]) else 1000
out_dir  <- if (length(args) >= 4) args[4] else "fst_gene_plots"
dir.create(out_dir, showWarnings = FALSE)

# ---- Read the BED file -------------------------------------------------------
# BED starts are 0-based, so add 1 to get the usual 1-based start position.
bed <- read.table(bed_file, sep = "\t", header = FALSE,
                  col.names = c("chrom", "start", "end", "gene"),
                  colClasses = c("character", "numeric", "numeric", "character"))
bed$start <- bed$start + 1

# ---- Read the FST file ---------------------------------------------------------
fst <- read.table(fst_file, header = TRUE, sep = "\t",
                  colClasses = c(CHROM = "character"))
windowed <- "BIN_START" %in% colnames(fst)
if (windowed) {
  fst$fst <- fst$WEIGHTED_FST
} else {                                   # per-site file
  fst$fst <- fst$WEIR_AND_COCKERHAM_FST
  fst$BIN_START <- fst$POS
  fst$BIN_END   <- fst$POS
}
fst <- fst[!is.na(fst$fst), ]              # drop "nan" values

# ---- One plot per gene -------------------------------------------------------
pdf(file.path(out_dir, "all_genes.pdf"), width = 7, height = 4)   # all in one
summary_rows <- list()

for (i in seq_len(nrow(bed))) {
  g <- bed[i, ]
  reg_start <- g$start - flank
  reg_end   <- g$end + flank

  # Windows (or SNPs) on the same chromosome that overlap the region
  hits <- fst[fst$CHROM == g$chrom &
              fst$BIN_END >= reg_start &
              fst$BIN_START <= reg_end, ]

  if (nrow(hits) == 0) {
    message("No FST values found for ", g$gene, " (", g$chrom, ":",
            g$start, "-", g$end, ") - skipped")
    next
  }

  title <- paste0(g$gene, "  (", g$chrom, ":", format(g$start, big.mark = ","),
                  "-", format(g$end, big.mark = ","), ", +/- ", flank, " bp)")

  p <- ggplot() +
    # light shading: gene + flanks; darker shading: the gene itself
    annotate("rect", xmin = reg_start / 1e6, xmax = reg_end / 1e6,
             ymin = -Inf, ymax = Inf, fill = "steelblue", alpha = 0.12) +
    annotate("rect", xmin = g$start / 1e6, xmax = g$end / 1e6,
             ymin = -Inf, ymax = Inf, fill = "steelblue", alpha = 0.25) +
    labs(title = title, x = paste0("Position on ", g$chrom, " (Mb)"),
         y = if (windowed) "Weighted FST (window)" else "FST (per SNP)") +
    # Same 0-1 scale on every plot, so genes can be compared by eye
    # (FST can be slightly negative, so allow below 0 if needed)
    scale_y_continuous(limits = c(min(0, hits$fst), 1)) +
    theme_bw() +
    theme(plot.title = element_text(size = 11))

  if (windowed) {
    p <- p + geom_segment(data = hits,
                          aes(x = BIN_START / 1e6, xend = BIN_END / 1e6,
                              y = fst, yend = fst),
                          linewidth = 1, colour = "black", alpha = 0.6)
  } else {
    p <- p + geom_point(data = hits, aes(x = BIN_START / 1e6, y = fst), size = 1.5)
  }

  print(p)                                               # page in all_genes.pdf
  ggsave(file.path(out_dir, paste0(g$gene, ".png")), p,
         width = 7, height = 4, dpi = 300)

  summary_rows[[g$gene]] <- data.frame(
    gene = g$gene, chrom = g$chrom, start = g$start, end = g$end,
    n_values = nrow(hits), mean_fst = mean(hits$fst), max_fst = max(hits$fst))
}
invisible(dev.off())

# A small table with the mean and max FST around each gene
summary_table <- do.call(rbind, summary_rows)
write.table(summary_table, file.path(out_dir, "fst_gene_summary.tsv"),
            sep = "\t", quote = FALSE, row.names = FALSE)
cat("Plotted", nrow(summary_table), "of", nrow(bed), "genes. Output in", out_dir, "\n")
