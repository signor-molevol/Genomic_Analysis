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
```
## Last week we talked about flies that had evolve to have larger body size at higher altitudes

## Some of the data included in this study is as follows:
```
Ethiopian line 8N  SRR31835375
Ethiopian line 15N  SRR31835573
Ethiopian line 86N  SRR31835473
Ethiopian line 73N  SRR31835482
```

```
Zambian line 366N  SRR10729165
Zambian line 418N  SRR10733526
Zambian line 403N  SRR10729566
Zambian line 274N  SRR10729166
```

Zambian flies are lowland flies, Ethiopian flies are highland flies.


# What gene should we look at?


<img width="769" height="339" alt="Screenshot 2026-09-15 at 4 08 35 PM" src="https://github.com/user-attachments/assets/f78ffd9e-cd05-46c3-b472-246fe4683432" />

## In the paper, this was a gene with some of the most differentiation between Zambian and Ethiopian flies. 



## Last week we used fastp to trim adapters off of our reads


## I took the liberty of rearranging your files to be ready for today. You will be working in groups, please actually work together. 
```
table_1
table_2
table_3
table_4
```
You should each have a subfolder called pigmentation that contains your original files and your trimmed files. 

like this:

/visitor/table_1/pigmentation

Please move into that directory, based on what table you sit at. 


## Remove your untrimmed files. We have them backed up elsewhere so its not necessary to maintain copies. Be careful not to remove everything!

## The next step for finding out what variation is present in our population is to map our reads to the bbc gene. 

## We do this with a program called bwa. 

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

https://www.youtube.com/watch?v=Pk4TYf_Ut_E


## Then you map to the reference

```
bwa mem -t 10 bbc.fasta myreads.fastq > myreads.sam
```


## bwa mem is the program and type of mapping you want to use. -t 10 is the number of threads to use. bbc.fasta is the reference, followed by the reads. Then you output to a new file. THE NEW FILE MUST ALWAYS CONTAIN THE FILE ENDING OF .SAM

## Extra challenge: Writing a for loop for mapping. 

```
SRR10729165.lite.trim.1_1.fastq
SRR10729165.lite.trim.1_2.fastq

```

Loops are key to productivity improvements through automation as they allow us to execute commands repeatedly. Similar to wildcards and tab completion, using loops also reduces the amount of typing (and typing mistakes). Loops are helpful when performing operations on groups of sequencing files, such as unzipping or trimming multiple files. We will use loops for these purposes in subsequent analyses, but will cover the basics of them for now.

When the shell sees the keyword for, it knows to repeat a command (or group of commands) once for each item in a list. Each time the loop runs (called an iteration), an item in the list is assigned in sequence to the variable, and the commands inside the loop are executed, before moving on to the next item in the list. Inside the loop, we call for the variable’s value by putting $ in front of it. The $ tells the shell interpreter to treat the variable as a variable name and substitute its value in its place, rather than treat it as text or an external command. In shell programming, this is usually called “expanding” the variable.

Sometimes, we want to expand a variable without any whitespace to its right. Suppose we have a variable named foo that contains the text abc, and would like to expand foo to create the text abcEFG.

```
$ foo=abc
$ echo foo is $foo
foo is abc
$ echo foo is $fooEFG      # doesn't work
foo is
```


The interpreter is trying to expand a variable named fooEFG, which (probably) doesn’t exist. We can avoid this problem by enclosing the variable name in braces ({ and }, sometimes called “squiggle braces”). bash treats the # character as a comment character. Any text on a line after a # is ignored by bash when evaluating the text as code.

```
$ foo=abc
$ echo foo is $foo
foo is abc
$ echo foo is ${foo}EFG      # now it works!
foo is abcEFG

```

## So basically when you are using for loops you assign a variable, and as the computer finishes each iteration it places the next file on the list in the variable. 

Try typing:

```
for i in *.trim.1_1.fastq
do
head -1 $i
done
```

## But how do you use variables when you need to use files with different endings for the bwa command?

```
for i in *.trim.1_1.fastq
do
OUT=${i%.lite.trim.1_1.fastq}
echo $OUT
done
```

## Can anyone figure out how to write a for loop for mapping?


## Once you have sam files for every pair of reads, you need to convert them to another format called bam

The tool for this is called samtools.

The manual page is here:

https://www.htslib.org/doc/samtools.html

So just a refresh of our pipeline so far


```
FASTP --------> BWA INDEX ---------> BWA MEM -----------> SAMTOOLS VIEW
```

You can also type in samtools and it will print the options.

We use samtools to convert to a more compressed file type called bam, then we sort the reads by location.

```
samtools view -b file.sam -o file.bam
```

The -b flag tells the program to output as a bam file. 


```
samtools sort file.bam -o file.sorted.bam
```

Now if you are really brave, write a for loop for each of them!

Once you reach this step, you are ready to start looking for variation. 


## SAM format basics:

<img width="326" height="251" alt="image" src="https://github.com/user-attachments/assets/50fa3a00-13d6-44e8-8904-e25e06496edd" />



## Out of all of this information, one is particularly important and that is the FLAG

Flags are really messy, the are Binary encoding of a hexadecimal…..converted to a decimal……


<img width="383" height="267" alt="image" src="https://github.com/user-attachments/assets/30aa2cee-4732-4e47-9eb3-fe2aea856546" />


Luckily there is a website that will interpret flags for you:

https://broadinstitute.github.io/picard/explain-flags.html


## The other particularly important field is the MAPQ score. That tells you the confidence that the program has that it has found the right position for your read.

<img width="1088" height="588" alt="Screenshot 2026-09-20 at 4 28 04 PM" src="https://github.com/user-attachments/assets/9e59662d-3b61-4d4e-9e5c-12df47fae5b9" />


Lower MAPQ score = lower confidence that the read maps to that position. 


## If we have time, lets take a break from the computer and talk in our groups about ideas for projects. 

All kinds of possibilities: cold tolerance, transposons, copy number variation, pigmentation, geographic variation in general, etc. 

