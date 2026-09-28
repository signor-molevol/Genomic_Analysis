# From VCF to Allele Frequency Differences

This walks through turning the VCF from your `bcftools mpileup | bcftools call` command
into per-group allele frequencies, then plotting the difference between two groups of
4 samples each.

## Starting point

```bash
bcftools mpileup -Ou -f bbc.fasta \
    SRR10729165.sorted.bam SRR10729166.sorted.bam SRR10729566.sorted.bam SRR10733526.sorted.bam \
    SRR31835375.sorted.bam SRR31835473.sorted.bam SRR31835482.sorted.bam SRR31835573.sorted.bam \
    | bcftools call -mv -Ov -o body_size.vcf
```

This gives you genotype calls (`GT`) for all 8 samples at every variant site, but **no allele
frequency field yet** — that needs to be calculated explicitly, and separately for each group,
since a genotype call by itself is just 0/0, 0/1, or 1/1 for one individual.

## Step 1: Check your sample names

`bcftools mpileup` names samples after the BAM file paths by default, so confirm what they look
like before splitting into groups:

```
conda activate bio_env
```

```bash
bcftools query -l body_size.vcf
```

You should see something like `SRR10729165.sorted.bam`, `SRR10729166.sorted.bam`, etc.

## Step 2: Compress and index the VCF

The next steps need a compressed, indexed VCF (your `-Ov` output is plain text):

```bash
bgzip body_size.vcf
bcftools index body_size.vcf.gz
```

## Step 3: Define your two groups

Make two plain text files, one sample name per line, matching exactly what
`bcftools query -l` printed:

```bash
# group1.txt
SRR10729165.sorted.bam
SRR10729166.sorted.bam
SRR10729167.sorted.bam
SRR10729168.sorted.bam
```

```bash
# group2.txt
SRR10729169.sorted.bam
SRR10729170.sorted.bam
SRR10729171.sorted.bam
SRR10729172.sorted.bam
```

## Step 4: Split the VCF by group

```bash
bcftools view -S group1.txt body_size.vcf.gz -Oz -o group1.vcf.gz
bcftools view -S group2.txt body_size.vcf.gz -Oz -o group2.vcf.gz
```

## Step 5: Calculate allele frequency within each group

`bcftools +fill-tags` recalculates INFO tags (including `AF`, allele frequency) based on
**only the samples currently in the file** — which is exactly why we split into two files
first. Run it separately on each group:

```bash
bcftools +fill-tags group1.vcf.gz -Oz -o group1_af.vcf.gz -- -t AF
bcftools +fill-tags group2.vcf.gz -Oz -o group2_af.vcf.gz -- -t AF
```

## Step 6: Pull out just CHROM, POS, and AF

```bash
bcftools query -f '%CHROM\t%POS\t%INFO/AF\n' group1_af.vcf.gz > group1_af.tsv
bcftools query -f '%CHROM\t%POS\t%INFO/AF\n' group2_af.vcf.gz > group2_af.tsv
```

Each file now has one row per SNP: chromosome, position, and that group's allele frequency
(0 to 1) at that site.

## Step 7: Merge, compute the difference, and plot in R

```r

g1 <- read.table("group1_af.tsv", col.names = c("CHROM", "POS", "AF1"))
g2 <- read.table("group2_af.tsv", col.names = c("CHROM", "POS", "AF2"))


# merge on shared sites only
merged <- merge(g1, g2, by = c("CHROM", "POS"))

# drop any sites where AF couldn't be calculated in one group
# (e.g. no called genotypes in that subset)

merged <- na.omit(merged)
merged$AF_diff <- merged$AF1 - merged$AF2

plot(merged$POS, merged$AF_diff,
     pch = 19, col = "steelblue",
     xlab = "Position in gene", ylab = "Allele frequency difference (Group1 - Group2)",
     main = "Allele frequency difference along bbc")
abline(h = 0, lty = 2, col = "grey40")








