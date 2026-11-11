#!/bin/bash
###############################################################################
# Option 2, step 1: allele frequencies in each species (vcftools)
#
# What you need:
#   - A VCF with samples from both species, mapped to the same reference
#   - mel.txt and sim.txt: sample names of each species, one per line
#   - vcftools
#
# How to run:   bash species_allele_freqs.sh
# Then:         Rscript dxy_windows.R mel_freq.frq sim_freq.frq
###############################################################################

set -e

VCF="my_data.vcf.gz"     # your VCF
SP1="mel.txt"            # samples of species 1
SP2="sim.txt"            # samples of species 2

# vcftools reads .vcf.gz with --gzvcf and plain .vcf with --vcf
if [[ "$VCF" == *.gz ]]; then INPUT="--gzvcf $VCF"; else INPUT="--vcf $VCF"; fi

# For each species, calculate the frequency of each allele at every SNP.
#   --keep               only use the samples of this species
#   --remove-indels      SNPs only
#   --min-alleles 2      biallelic SNPs only (two alleles across the
#   --max-alleles 2      whole VCF, i.e. both species together)
#   --freq2              write allele frequencies (without allele letters)
#
# Output (one file per species), one row per SNP:
#   CHROM  POS  N_ALLELES  N_CHR  FREQ_REF  FREQ_ALT
#   N_CHR = number of chromosomes (allele copies) with a genotype call,
#           e.g. 10 diploid flies with no missing data -> N_CHR = 20
for SP in "$SP1" "$SP2"; do
    NAME=$(basename "$SP" .txt)
    vcftools $INPUT \
        --keep "$SP" \
        --remove-indels --min-alleles 2 --max-alleles 2 \
        --freq2 \
        --out "${NAME}_freq"
done

echo "Done: wrote $(basename "$SP1" .txt)_freq.frq and $(basename "$SP2" .txt)_freq.frq"
