Now we want to plot the FST values from the other day.

We have a script in R that will do that for us, and generate one plot per gene.

it is called plot_fst.R

You will want to make a file for that script on the server, and copy and paste it in.

You can run it as follows:
```
Rscript plot_fst_regions.R genes.bed fst_file [flank_bp] [output_folder]
```

genes.bed should be your candidate gene bed file.

fst_file should be your per site FST (not windowed)

flank_bp should be the size of the flanks you want to include, for example 1000 bp (recommended)

Output folder is where you want it to store the output.

Then, if you want to see what the 'outlier' value is, you can do the following:
```
Rscript fst_outliers.R fst_windows.windowed.weir.fst 1000 10
```

This tells you the top 1% of windows for the genome. 
This extracts the actual windows that are outliers:

```
grep "TRUE" fst_windows_outliers.tsv > fst_outliers.bed
```

This tells you if it overlaps any of your candidate genes:

```
bedtools intersect -wao -a candidate_genes.bed -b fst_outliers.bed
```
