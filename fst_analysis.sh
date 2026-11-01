#!/bin/bash
###############################################################################
# Basic VCF analysis and FST between two populations using vcftools
#
# What you need:
#   1. A VCF file (can be compressed, ending in .vcf.gz, or plain .vcf)
#   2. vcftools installed  (e.g. conda install -c bioconda vcftools)
#   3. Two text files listing which samples belong to which population,
#      one sample name per line, spelled exactly as in the VCF header:
#         pop1.txt        pop2.txt
#         sampleA         sampleD
#         sampleB         sampleE
#         sampleC         sampleF
#
# How to run:   bash fst_analysis.sh
#
# Background, in one paragraph:
#   A VCF (Variant Call Format) file is a table of positions in the genome
#   where individuals differ from the reference genome. Each row is one
#   variant (e.g. a SNP, a single-letter change), and each column after the
#   first nine is one individual's genotype at that variant, e.g. 0/0
#   (two copies of the reference allele), 0/1 (one of each) or 1/1 (two
#   copies of the alternative allele). ./. means the genotype is missing.
#
#   FST measures how genetically different two populations are. It ranges
#   from 0 (the populations have the same allele frequencies, so no
#   differentiation) to 1 (completely different alleles fixed in each
#   population). As a rough guide: < 0.05 little, 0.05-0.15 moderate,
#   0.15-0.25 great, > 0.25 very great differentiation.
###############################################################################

# Stop the script immediately if any command fails
set -e

# ---- Settings: change these to match your files ----------------------------
VCF="my_data.vcf.gz"     # your VCF file
POP1="pop1.txt"          # sample names in population 1
POP2="pop2.txt"          # sample names in population 2
OUT="results"            # folder where all output goes
mkdir -p "$OUT"

# vcftools reads .vcf.gz with --gzvcf and plain .vcf with --vcf
if [[ "$VCF" == *.gz ]]; then INPUT="--gzvcf $VCF"; else INPUT="--vcf $VCF"; fi


###############################################################################
# STEP 1: Look at the raw data
###############################################################################
# Before analysing anything, check what is in the file.

# How many samples are there, and what are they called?
# (bcftools query -l does this too; here we read the header line directly.)
echo "== Samples in the VCF =="
zcat -f "$VCF" | grep -m 1 "^#CHROM" | cut -f 10- | tr '\t' '\n'

# How many variants are there? Lines starting with # are header lines,
# every other line is one variant, so we count the non-# lines.
echo "== Number of variants =="
zcat -f "$VCF" | grep -vc "^#"


###############################################################################
# STEP 2: Check data quality per individual
###############################################################################
# Missing data: what fraction of genotypes is missing (./.) for each sample?
# Output: results/raw.imiss  (column F_MISS = fraction missing)
# Samples with lots of missing data (say > 0.2-0.5) were probably sequenced
# poorly and may need to be removed.
vcftools $INPUT --missing-indv --out "$OUT/raw"

# Heterozygosity: how many sites is each individual heterozygous (0/1) at?
# Output: results/raw.het  (column F = inbreeding coefficient)
# F near 0 is normal for an outbred individual; strongly positive F means
# fewer heterozygous sites than expected (inbreeding, or poor sequencing),
# strongly negative F can mean the sample is contaminated.
vcftools $INPUT --het --out "$OUT/raw"


###############################################################################
# STEP 3: Filter the variants
###############################################################################
# Not every variant in a raw VCF is reliable. We keep only those that pass
# a few simple filters, and write them to a new, cleaner VCF.
#
#   --remove-indels        keep SNPs only (insertions/deletions are harder
#                          to call accurately)
#   --min-alleles 2        keep sites with exactly two alleles ("biallelic"),
#   --max-alleles 2        which is what the FST calculation assumes
#   --max-missing 0.8      keep sites where at least 80% of individuals have
#                          a genotype (note: 1 = no missing data allowed)
#   --maf 0.05             minor allele frequency: drop sites where the rarer
#                          allele is below 5%; very rare alleles are often
#                          sequencing errors and carry little information
#   --minQ 30              drop sites with a variant quality score below 30
#                          (a 1 in 1000 chance the variant call is wrong)
#   --recode               write the sites that pass to a new VCF
#   --recode-INFO-all      keep all the INFO information in that new VCF
#
# Output: results/filtered.recode.vcf
# The screen output says how many sites were kept ("After filtering, kept
# ... out of a possible ... Sites").
vcftools $INPUT \
    --remove-indels \
    --min-alleles 2 --max-alleles 2 \
    --max-missing 0.8 \
    --maf 0.05 \
    --minQ 30 \
    --recode --recode-INFO-all \
    --out "$OUT/filtered"

FILTERED="$OUT/filtered.recode.vcf"


###############################################################################
# STEP 4: Calculate FST for every SNP
###############################################################################
# --weir-fst-pop is given once per population. vcftools uses the
# Weir & Cockerham (1984) method, the most widely used FST estimator.
#
# Output: results/fst_per_site.weir.fst with three columns:
#   CHROM  POS  WEIR_AND_COCKERHAM_FST
# Some values may be "nan" (not a number) - that happens at sites where
# the calculation is not possible, e.g. both populations are identical
# and have no variation there. Small negative values can also appear;
# they are an artefact of the estimator and are treated as 0.
#
# The overall FST for the whole genome is printed at the end of the
# screen output. "2>&1 | tee" copies that screen output into a file
# (results/fst_per_site.log) so you can find it again later:
#   "Weir and Cockerham weighted Fst estimate" <- use this one
#   "Weir and Cockerham mean Fst estimate"     (simple average of sites)
vcftools --vcf "$FILTERED" \
    --weir-fst-pop "$POP1" \
    --weir-fst-pop "$POP2" \
    --out "$OUT/fst_per_site" 2>&1 | tee "$OUT/fst_per_site.log"


###############################################################################
# STEP 5: Calculate FST in windows along the genome
###############################################################################
# FST for a single SNP is very noisy. Averaging over windows (stretches of
# the genome) gives a smoother picture and makes it easier to spot regions
# where the populations are unusually different, which could point to
# genes under selection.
#
#   --fst-window-size 50000   each window is 50,000 bp long
#   --fst-window-step 10000   start a new window every 10,000 bp, so the
#                             windows overlap (a "sliding window")
#
# Output: results/fst_windows.windowed.weir.fst with columns:
#   CHROM  BIN_START  BIN_END  N_VARIANTS  WEIGHTED_FST  MEAN_FST
# N_VARIANTS = how many SNPs were in that window. Windows with very few
# SNPs give unreliable values.
vcftools --vcf "$FILTERED" \
    --weir-fst-pop "$POP1" \
    --weir-fst-pop "$POP2" \
    --fst-window-size 50000 \
    --fst-window-step 10000 \
    --out "$OUT/fst_windows"


###############################################################################
# STEP 6: Summarise the results
###############################################################################
echo
echo "== Genome-wide FST =="
grep "Fst estimate" "$OUT/fst_per_site.log"

# The 10 windows with the highest FST: candidate regions where the two
# populations differ most. sort -k5,5gr sorts by column 5 (WEIGHTED_FST),
# largest first; head -n 10 shows the top 10.
echo
echo "== Top 10 most differentiated windows =="
head -n 1 "$OUT/fst_windows.windowed.weir.fst"
tail -n +2 "$OUT/fst_windows.windowed.weir.fst" | sort -k5,5gr | head -n 10

echo
echo "Done. All output files are in the '$OUT' folder."
