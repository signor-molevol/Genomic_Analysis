# Illumina sequencing is what gave us genomics

## Quick breakdown of the technology:

https://youtu.be/fCd6B5HRaZ8?si=68ZqTO2p2wRX-tUW


## How is illumina sequencing an extension of traditional PCR? Can you think of two similarities?


Read lengths are limited to about 150 bp because of the sequencing chemistry

The output is in a format called FASTQ

First lets look at what FASTA file formats are
```
>sequence
ATCGTTTTTACTGAAGGCCATCGAACT
```
Always a header that begins with > and the sequence on the next line

## FASTQ files include quality scores for each base that give some confidence in the base call

A fastq file is a text file with information on the quality of the sequence data

Although it looks complicated (and it is), it’s easy to understand the fastq format with a little decoding. Some rules about the format 
include…

| Line	| Description |
|-------|-------------|
| 1	| Always begins with ‘@’ and then information about the read |
| 2	| The actual DNA sequence|
| 3	| Always begins with a ‘+’ and sometimes the same info in line 1 |
| 4	| Has a string of characters which represent the quality (phred) scores; must have same number of characters as line 2 |


Here is an example of a fastq file:

```
@ERR059938.60 HS9_6783:8:2304:19291:186369#7/2
GTCTCCGGGGGCTGGGGGAACCAGGGGTTCCCACCAACCACCCTCACTCAGCCTTTTCCCTCCAGGCATCTCTGGGAAAGGACATGGGGCTGGTGCGGGG
+
7?CIGJB:D:-F7LA:GI9FDHBIJ7,GHGJBKHNI7IN,EML8IFIA7HN7J6,L6686LCJE?JKA6G7AK6GK5C6@6IK+++?5+=<;227*6054
```


