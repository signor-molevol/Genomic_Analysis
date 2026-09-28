## Review commands
```
ls - list contents of your current location
pwd - print your current location
mkdir - make directory
cd - change directory
cp - copy
mv - move
nano file.txt - open and create a file
head/tail - print first and last lines
sed - text stream editor
grep - search for pattern
> - direct output to a file
rm - remove
tab - autocomplete
.. - up one directory
. - current directory


for i in *
do
done


## New command of the day is:

```
     |
```

This is the pipe command. It allows you to direct data to a new command without writing it into a file. 

For example:

 cat bbc.fasta | sed '1d'

## Today we are going to call variants for our bbc gene from the previous day. Open up your GitHub and document your code as you go along. 

I spent hours trying to get bcftools running without delving into what is next, but our system is to outdated.

We are going to use something called conda to run bcftools. 

Conda is an environment manager. Imagine you wanted to run two programs, but one required python 2 and the other required python 3. How are you going to manage both installations on your computer?

One way is conda - it creates a container with the right dependencies for whatever program you need to run. 

So before we do variant calling, type this:

```
conda activate bio_env

```

Now type in :

```
bcftools
```

And press enter. Take a second to look over the output. 

We are going to use two commands to call alleles in our bam files

```
	mpileup
	call
```	
	
### Calculate likelihoods	
What mpileup does is call variants in the file. It basically slices each base in the reference and looks
across all the aligment files you give it. Then it calls the likelihood of each bam file having
each genotype (for example A/A, A/T, or T/T). This includes data like coverage at the base, quality
of mapping at the base, etc. 


<img width="1088" height="706" alt="image" src="https://github.com/user-attachments/assets/1bde13b2-575b-4ee0-9df3-8a722c30742b" />


### Call variants
call actually calls the variants. It takes the genotype likelihoods and quality information from the last step
and uses to to calculate the total likelihood of a given genotype at a position

### At the end of this, you will have a file called a VCF file (so make sure you use that file ending)

The command looks like this:

````
bcftools mpileup -Ou -f bbc.fasta SRR10729165.sorted.bam SRR10729166.sorted.bam... | bcftools call -mv -Ov -o body_size.vcf
```

Can you guys look at the bcftools manual (by typing bcftools mpileup for example)
to see what the flags mean for both commands?

You want to call SNPs on all your files simultaneously, so I have '...' there but you want to list all your bam
files. 



When your command is complete, open up your vcf file and look over the format




CHROM: The chromosome or reference contig identifier.


POS: The 1-based coordinate position on the reference genome.


ID: Unique identifier for the variant (such as a rsID from dbSNP) or a dot (.) if none.


REF: The reference base(s) on the forward strand.


ALT: The alternate non-reference allele(s) observed.


QUAL: Phred-scaled quality score for the variant assertion.


FILTER: Pass status or reason for failing specific quality filters.


INFO: Additional semi-colon-separated key-value pairs containing extra annotation data about the variant.


Again all of these file types are very specific, so make sure to use the right file ending so that
you keep everything organized.


# Looking for ideas for Drosophila projects. 

1. Brainstorm something that interests you. Almost any topic has been looked at in Drosophila, and
sometimes there are documented phenotypes. The populations on our server are from Egypt, Ethiopia,
France, South Africa, and Zimbabwe. You are free to stick to these. You could do things like look at
a set of genes that interest you (i.e. Odorant receptors), or something with copy number variation.

For example, this paper is on copy number variation:

https://academic.oup.com/mbe/article/33/5/1308/2579856

You could look at phenotypes like pigmentation, wing size, etc. There may be information for some lines on
alcohol tolerance (actually there is, I can help with that). I encourage you to poke around and come
up with a few options.

## What data did they use?

Places to look: The data availability statement, supplemental files, or search the document for key words
SRA, Bioproject, etc. 

They data they used may not be appropriate for this work - for example I would discourage using pooled data. 

You also don't want to do exactly what they did. Look at what other people have done and find a way to make
it smaller - you aren't writing a research paper - and put your own spin on it. 

Then you can ask, is there a way I can use different data to come at this question from a
different angle?

For example:

https://pubmed.ncbi.nlm.nih.gov/27777283/



In this paper cold adapted flies are from Ethiopia, and warm adapted flies are from France. We probably have at
least a subset of these flies.

Look at the supplemental information, they have phenotypes published for them.

One idea would be to look at some genes from this paper you think are interesting, then
compare to ND flies once we have the data. 

No problem if you guys want to look at this, but everyone has to look from a different angle -
two groups can't ask the same question.


Start poking around - Start a file with the following information:

1. Paper URL or name
   
2. Basic question
   
3. What data they used/what comparison
   
4. Is there phenotype information?
   
5. Possible direction your inquiry could take. 

Try to come up with two options before the end of class and send them to me. 

