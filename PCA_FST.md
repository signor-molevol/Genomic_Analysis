If you are ready to do your FST and PCA analysis, great! 

One step I didn't mention previously that you will want to do is remove all non-major chromosomes from your VCF file.

You can run the following code, replacing 'input.vcf.gz' with the name of your file, and 'filtered.vcf.gz' with whatever you want the output to be. 
```
bcftools view -t X,2L,2R,3L,3R -Oz input.vcf.gz -o filtered.vcf.gz
```


We already walked through how to do the FST analysis, so hopefully that made sense. 

make sure you activate conda:

```
conda activate bio_env
```

You can pretty much enter each line of the following, withe your file names in place of the generic names, on the command line.

```
VCF="my_data.vcf.gz"     # your VCF file
POP1="pop1.txt"          # sample names in population 1
POP2="pop2.txt"          # sample names in population 2
OUT="results"            # folder where all output goes
mkdir -p "$OUT"
```
Then you can enter each line of the FST script verbatim by just copy and pasting.

PCA will be done entirely in R, so it requires a little bit of a different approach. This will produce your PCA plot, and we will discuss making FST plots next. 

There is a script on here titled 'PCA.R'. you will need to copy it into a file on the server. You can call it the same thing. Do something like this:

```
nano PCA.R
```
then copy the script and save it.

Copy the name of your VCF file, then open the PCA script.

You will see this at about line 46:
```
vcf_file   <- "my_data.vcf.gz"            # your VCF
pop_files  <- c("pop1.txt", "pop2.txt")   # list as many population files as
                                          # you have, e.g. add "pop3.txt"
out_prefix <- "pca"                       # names of output files
 
max_missing <- 0.1    # drop SNPs missing in more than 10% of samples
min_maf     <- 0.05   # drop SNPs whose rarer allele is below 5% frequency
thin_bp     <- 100    # keep at most one SNP per 100 bp (0 = no thinning);
                      # see STEP 6 for why this suits Drosophila
```

Edit this section so it matches your files. so "my_data.vcf.gz" should become "ethanol.vcf" or whatever. If you have three populations, you can list three pop files. 
You don't need to edit the bottom portion unless you think you have a reason to (i.e. the max-missing and whatnot).

Close the script and save it.

To run, do this:

```
Rscript pca.R
```
press enter and wait. 

You can either download the output (if your computer supports that) using scp:
```
scp -r visitor@134.129.113.23:/storehouse/visitor/table_#/ .
```
Or you can ask me to and I'll email it to you. 

This is generally what a PCA looks like:

<img width="734" height="570" alt="Screenshot 2026-11-11 at 12 37 51 PM" src="https://github.com/user-attachments/assets/a849968a-0d32-4263-b86b-0d64086fea87" />


And what it is telling you is where the variation in the group is coming from - your dots are colored by population, so if they are grouping by color then the populations are more similar to each other than to other populations. Weird outliers and groupings are generally the sign of a problem. 
