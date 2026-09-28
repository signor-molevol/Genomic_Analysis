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
