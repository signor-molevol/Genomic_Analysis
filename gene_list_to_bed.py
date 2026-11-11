#!/usr/bin/env python3
"""
Make a BED file (chr  start  end  gene) for a list of genes from a FlyBase GTF.

Usage:
  python genes_to_bed.py dmel-all-r6.xx.gtf.gz gene_list.txt genes.bed

gene_list.txt: one gene per line, either the symbol (e.g. Adh) or the
FlyBase ID (e.g. FBgn0000055). Gene coordinates span all of the gene's
features in the GTF. BED starts are 0-based, so start = GTF start - 1.
"""
import gzip
import re
import sys

gtf, gene_list, out = sys.argv[1:4]

wanted = [g.strip() for g in open(gene_list) if g.strip()]
wanted_set = set(wanted)

genes = {}  # gene (as listed) -> [chrom, start, end]
opener = gzip.open if gtf.endswith(".gz") else open
with opener(gtf, "rt") as fh:
    for line in fh:
        if line.startswith("#"):
            continue
        f = line.rstrip("\n").split("\t")
        if len(f) < 9:
            continue
        ids = re.findall(r'(?:gene_id|gene_symbol) "([^"]+)"', f[8])
        hit = next((i for i in ids if i in wanted_set), None)
        if hit is None:
            continue
        chrom, start, end = f[0], int(f[3]), int(f[4])
        if hit in genes:
            g = genes[hit]
            g[1], g[2] = min(g[1], start), max(g[2], end)
        else:
            genes[hit] = [chrom, start, end]

with open(out, "w") as o:
    for name in wanted:
        if name in genes:
            chrom, start, end = genes[name]
            o.write(f"{chrom}\t{start - 1}\t{end}\t{name}\n")

missing = [g for g in wanted if g not in genes]
print(f"Wrote {len(wanted) - len(missing)} of {len(wanted)} genes to {out}")
if missing:
    print("Not found in GTF:", ", ".join(missing))
