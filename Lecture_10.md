
## We found some allele frequency differences. What does it all mean?

Lets learn more about the bbc gene.

First, log back into the server and navigate to your pigmentation directory. 

## Where are the genetic variants?

In order to find out where the alleles are, we need to annotate the bbc gene. Lets go to a website called flybase.org for this. 

In the 'Jump to gene' box on the right hand size, type bbc and press enter.

Once you are on the bbc page, you should see a button the left hand side that says 'Jbrowse'. Click on that. 

Once you have examined the exon structure of bbc, go back to the gene page. Look for the 'Get sequence' drop down menu. Select 'exons' and press 'Get sequence'. I have already taken the pleasure of uploading the exons to the github, as well as the gff3 file. Lets take a look at both. 

We are going to use the bbc.gff file to annotate our bbc allele frequency graph from last week. 

Open the file and take a look. GFF is a specific file format, which you are looking at. 

## Column 1

"seqid" Accession.version of the annotated genomic sequence. NCBI files universally use accession.version because it provides an unambiguous identifier for the annotated sequence, and does not require additional knowledge of the species, assembly and version, and data source. We strongly recommend using accession.version instead of ambiguous seqids such as 'chr1' to avoid errors due to mis-associating features with the wrong genomic location.

## Column 2
"source" For annotations produced by one of NCBI's pipelines, the method used to generate the annotation is provided in column 2. The method is found in the ModelEvidence object in ASN.1 format, and appears in the flatfile format as a structured note. For example: "Derived by automated computational analysis using gene prediction method: BestRefSeq"

## Column 3

"type" The SOFA feature type most equivalent to the feature found in the source annotation. The original GenBank feature type is also provided by the "gbkey" attribute in column 9.

## Columns 4 & 5
"start" and "end" Start and end coordinates of the feature in 1-based coordinates. Note two exon or CDS rows of the same feature may overlap or be separated by an artificial "micro-intron" in order to represent cases of ribosomal slippage or putative assembly errors. See Additional Details below for more information.

## Column 6
"score" Currently only provided for alignments, if they contain a score named "score". The definition of this score may vary depending on the type of alignment.

## Column 7
"strand" The strand of the feature

## Column 8
"phase" The phase of the CDS feature, which is related to /codon_start in the flatfile specification. The phase is computed based on the known phase at the start of the CDS and computed for subsequent CDS rows. It may not be accurate if the CDS contains internal frameshifts, which can occur in pseudogenes and in genomes with indels, assembly gaps, and other errors. See Additional Details below for more information.

## Column 9

"attributes" A semicolon delimited list of official and additional attributes describing the feature.
ID A unique identifier for the feature. Most IDs are generated on-the-fly during file generation. They are not intended to be used as stable feature identifiers, and they are likely to change between annotation versions. Multiple rows with the same ID designate a single feature that is composed of multiple parts, most common for CDSes and multi-exon alignments but possible for other feature types as well. Note other attributes such as gene symbols, GeneIDs, and transcript or protein accessions may occur on multiple features, whereas the ID is globally unique for an individual file.

Parent ID of the parent of the feature

Dbxref A set of comma-separated tag:ID pairs corresponding to the /db_xref qualifiers provided in the source annotation. Note that database IDs can contain colons, so a format such as "HGNC:HGNC:1100" is expected and should be parsed on the first colon. See NCBI's documentation on the db_xref qualifier for more details, including URLs corresponding to specific database tags.

Name A suggested display name for the feature, currently populated for specific features: region "landmark" feature -- chromosome or linkage group, if available gene -- gene symbol or locus_tag RNA (multiple types) and CDS -- product accession.version (if exists)

Note feature comment. This appears as a /note qualifier in the GenBank format. Additional text may appear in the flatfile /note that internally is not part of a comment, and is not included in the GFF3 Note attribute.


## Now go back to your server window

Type:

```
nano bbc.gff
```

Copy and past the contents of the gff file into this new file. Close the file and save.

## Open a new R window.

Load your data

```
g1 <- read.table("group1_af.tsv", col.names = c("CHROM", "POS", "AF1"), na.strings = ".")
g2 <- read.table("group2_af.tsv", col.names = c("CHROM", "POS", "AF2"), na.strings = ".")

merged$AF1 <- as.numeric(merged$AF1)
merged$AF2 <- as.numeric(merged$AF2)
merged$AF_diff <- merged$AF1 - merged$AF2

```

This is all the same code as last week. 

Now you are going to create an additional table that includes the position of the CDS:
```
gene_start <- 2001
gene_end   <- 10229
cds <- data.frame(start = c(2392, 4968, 5270, 5992, 6990, 7815, 8731, 8954),
                  end   = c(2612, 5208, 5428, 6123, 7121, 7946, 8889, 9295))
```
Look at the cds data.frame by typing cds and pressing enter


open a new pdf

```
pdf('merged_annotated.pdf')

plot(merged$POS, merged$AF_diff, type = "n",
     xlab = "Position in bbc.fasta",
     ylab = "Allele frequency difference (Group1 - Group2)",
     main = "Allele frequency difference along bbc")
rect(gene_start, -1, gene_end, 1, col = "grey92", border = NA)
rect(cds$start, -1, cds$end, 1, col = "lightgoldenrod", border = NA)
abline(h = 0, lty = 2, col = "grey40")
points(merged$POS, merged$AF_diff, pch = 19, col = "steelblue")
dev.off()
```

This is the same code as last time, but the two rect lines create rectangles where the gene features are. Have at least one member of your group download the resulting pdf using the scp command from last week and view the file. 

The rect command follows this format:

```
rect(xleft, ybottom, xright, ytop)
```

Because allele frequencies are between 1 and -1, that is why we have those entries there. 

Now lets look at the graph. Where are our SNPs?

## Lets actually annotate each SNP. Keep open your R window, and either have a different group member do this part or open a second window and sign into the server.

```
conda activate bio_env
bcftools csq -s - -f bbc.fasta -g bbc.gff3 group1_biallelic.vcf.gz -Oz -o group1_csq.vcf.gz
bcftools query -f '%POS\t%INFO/BCSQ\n' group1_csq.vcf.gz > csq_group1.tsv
```

Look at the bcftools manual page to understand what bcftools csq is
```
https://samtools.github.io/bcftools/bcftools.html#csq

```

Do this for both of your groups and look at the output. What do you see?

Lets actually look at where they are in R

```
merged$region <- "intron"
merged$region[merged$POS <= 2000 | merged$POS >= 10230] <- "flank"
merged$region[merged$POS >= 2001 & merged$POS <= 2391] <- "UTR"
merged$region[merged$POS >= 9296 & merged$POS <= 10229] <- "UTR"
in_cds <- sapply(merged$POS, function(p) any(p >= cds$start & p <= cds$end))
merged$region[in_cds] <- "CDS"

table(merged$region)
aggregate(abs(AF_diff) ~ region, data = merged, FUN = mean)

# the 10 SNPs with the largest differences, and where they fall
head(merged[order(-abs(merged$AF_diff)), c("POS", "AF_diff", "region")], 10)
```

As you execute each line of code, lets look at the output and see what we have done.

Enter the first line containing 'intron'

Now type in merged and look at the output. How has it changed?

## What do you notice about your SNPs? Do you think they are functional? 
