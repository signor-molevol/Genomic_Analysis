
## We found some allele frequency differences. What does it all mean?

Lets learn more about the bbc gene.

First, log back into the server and navigate to your pigmentation directory. 

Start an instance of R by typing:

```
R
```

Now you can leave that window open for a minute while we learn about bbc.

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



