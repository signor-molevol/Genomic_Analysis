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


