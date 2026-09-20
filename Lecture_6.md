## Review commands

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



## Next type in bwa and press enter. You should see this:
```
Program: bwa (alignment via Burrows-Wheeler transformation)
Version: 0.7.17-r1188
Contact: Heng Li <lh3@sanger.ac.uk>

Usage:   bwa <command> [options]

Command: index         index sequences in the FASTA format
         mem           BWA-MEM algorithm
         fastmap       identify super-maximal exact matches
         pemerge       merge overlapping paired ends (EXPERIMENTAL)
         aln           gapped/ungapped alignment
         samse         generate alignment (single ended)
         sampe         generate alignment (paired ended)
         bwasw         BWA-SW for long queries

         shm           manage indices in shared memory
         fa2pac        convert FASTA to PAC format
         pac2bwt       generate BWT from PAC
         pac2bwtgen    alternative algorithm for generating BWT
         bwtupdate     update .bwt to the new format
         bwt2sa        generate SA from BWT and Occ

Note: To use BWA, you need to first index the genome with `bwa index'.
      There are three alignment algorithms in BWA: `mem', `bwasw', and
      `aln/samse/sampe'. If you are not sure which to use, try `bwa mem'
      first. Please `man ./bwa.1' for the manual.
```

## The first step is indexing the reference

```

bwa index bbc.fasta

```

This should only take a second.


## Then you map to the reference

```
bwa mem -t 10 bbc.fasta myreads.fastq > myreads.sam
```

https://www.youtube.com/watch?v=Pk4TYf_Ut_E










