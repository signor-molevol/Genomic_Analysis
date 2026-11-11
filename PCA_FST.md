If you are ready to do your FST and PCA analysis, great! 

One step I didn't mention previously that you will want to do is remove all non-major chromosomes from your VCF file.

You can run the following code, replacing 'input.vcf.gz' with the name of your file, and 'filtered.vcf.gz' with whatever you want the output to be. 
```
bcftools view -t X,2L,2R,3L,3R -Oz input.vcf.gz -o filtered.vcf.gz
```


We already walked through how to do the FST analysis, so hopefully that made sense. 
