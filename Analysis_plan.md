1. Introduction

2. List of genes

3. Analysis plan


A very basic analysis plan might look something like this:

<img width="798" height="459" alt="Screenshot 2026-11-01 at 3 17 32 PM" src="https://github.com/user-attachments/assets/96193053-670e-4899-b20a-a4bee503e6c6" />

### Calculate likelihoods	
What mpileup does is call variants in the file. It basically slices each base in the reference and looks
across all the aligment files you give it. Then it calls the likelihood of each bam file ha
ving
each genotype (for example A/A, A/T, or T/T). This includes data like coverage at the base, quality
of mapping at the base, etc. 


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






