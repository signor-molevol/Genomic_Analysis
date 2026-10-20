# Genomic analysis project step 2: Mapping your data

## Fastp

Check your files and make sure that fastp ran successfully on all files. If it didn't, run it now. If you have nanopore or pacbio data you do not need to run fastp.


## Next question: What is your reference? 

You have to map your reads to something. Are you using Drosophila melanogaster? Drosophila simulans? How will you compare them.

Most of you probably are using Drosophila melanogaster. 

## Available references

1. D. melanogaster

/storehouse/visitor/reference/dmel-all-chromosome-r6.69.fasta

2. D. simulans

/storehouse/visitor/reference/GCF_016746395.2_Prin_Dsim_3.1_genomic.fna


Please use the absolute path to these references when mapping your reads


## Mapping

The format is:


```

bwa mem -t 10 reference.fasta file1.fastq file2.fastq > file.sam

```

use tmux to start an unlinked session:

```
tmux
```

Write a for loop to map all of your files to the appropriate reference. If you are doing two species you will need to write two loops. 

Look at your github to remind yourself how to write the loop.

## Project

If you are still working out your exact question, thats ok. Getting your mapping going can happen concurrently.

Working on your annotated bibliography will help you focus the question.

Make sure to get your group members contact. If you don't finish the annotated bibliography by the end of class, you need to finish it outside of class. 

