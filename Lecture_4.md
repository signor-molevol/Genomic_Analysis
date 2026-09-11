# A brief refresher on file types

## When you see a file like this: SRR236768.fastq

FASTQ: File type

SRR236768: File name

Think of your computer, when you work with .xlsx or .docx or .txt files. 

Those are all file types, and they tell your computer what format they are in. 

FASTQ is a universal file type identifier. You can look up what FASTQ means on the internet in terms of format.

SRR236768 means nothing outside the context of the NCBI SRA. 

# sed commands from last week

sed stands for stream editor. It reads the the input, modifies it in some way, and outputs it. 

## sed 'NUMq;d' file

In your case sed '4q;d'

4q - prints each line until line 4

d - deletes all lines up until q minus 1 (lines 1 through 3)

## sed -n '4p' file

p means print the pattern, 4 calls the line

-n suppresses the default sed behavior to print all lines, and only prints the 4th


# Creating, moving, copying, and removing

Now we can move around in the file structure, look at files, and search files. 

But what if we want to copy files or move them around or get rid of them? 

```
cp
```
cp means copy. The syntax is:

```
cp inputfile.fastq outputfile.fastq
```
Can include paths to make a copy in a different location, as follows:

```
cp inputfile.fastq /home/sarah/outputfile.fastq
```

## Create a back up directory to put your copy in, like you might if you needed to save an unmodified version of your data

What command would you use?

## Now move the copy of your file into the backup directory. For this we use the mv command, which means move

```
mv file.fastq directory
```

If you replace directory with a file name, it will just rename the file instead of moving locations.

## Removing files

```
rm file.txt
```

rm is a very powerful and scary command. Always use it with caution. The internet is full of people that deleted months of work or half their operating system with the rm command. 

Move into your backup directory.

Remove the fastq file you created there.

Move back to your original directory. 

Now try to remove your backup directory. What happens?

```
rm -r backup
rmdir backup
```

Both will work on your current backup directory. The difference is that for rmdir the directory must be empty. 

# Searching files

```
grep
```

Grep allows you to search text files for patterns, and output those patterns. 

try running the following on your fastq file:
```
grep 'AAAAAAATAAGAAT' SRR3585777.fastq

```

You most likely got a whole lot of output to your terminal. What do you notice about it?

Lets say you got these reads, but you want to know more about them. Like which reads they are, and what quality. You can use flags to return adjacent lines with grep.
```
-A means after
-B means before

```

If you want the read identifier and the quality score, you would do something like this:

```
grep -A2 -B1 'AAAAAAATAAGAAT' SRR3585777.fastq
```

Your last line of output should look something like this:

```
@SRR3585777.4705849 HISEQ2500:113:C4K51ACXX:2:2312:8538:36724 length=110
AATTATTAATATTTTTAAGCACTTTGGCTATGGCTTTATCTAAGTTTCTCGACCCTAAGTTGGATTTGACCTTCAAAAAAATATTTGGCACTGAAAAAAATAAGAATATT
+SRR3585777.4705849 HISEQ2500:113:C4K51ACXX:2:2312:8538:36724 length=110
BBBFFFFFFFFFFIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIFFFFFFFFFFFFFBBFFFFFFFFFFFFFFBFFFFFF
```

Try running this commmand:

```
grep -B1 'ACTGATCAGAGCTGGAGTTCCGCAAGGCAGTGTGCTCGGACCAATACTGTACACCCT' SRR3585777.fastq
```
Now copy the last line of the output and navigate to this website:

https://blast.ncbi.nlm.nih.gov/Blast.cgi


Then this website:

https://www.dfam.org/home


## How to save your output to a new file instead of outputting it onto the screen

```
>
```

The carrot

```
grep -B1 'ACTGATCAGAGCTGGAGTTCCGCAAGGCAGTGTGCTCGGACCAATACTGTACACCCT' SRR3585777.fastq > G6.fasta
```

Now open G6.fasta and check what is in there. 


# Class activity

Find a drosophila simulans gene and select a small portion of it. 

Search for it in the fastq file. 

Redirect the output to a file, and name the file after the gene. 

Blast one of the sequences and make sure it is what you think it is. 

Create a document with the following in it: 

1. The sequence you are searching and the name of the gene you chose
2. The code you used to get the sequence
3. The number of lines in your output file
4. A screenshot of your blast output

   Email to me at: sarah.signor@ndsu.edu

Where do we find Drosophila genes?

Here are some options: ebony, yellow, Gpdh, Ddc, Adh

<img width="1568" height="837" alt="Screenshot 2026-09-08 at 1 26 22 PM" src="https://github.com/user-attachments/assets/c503ad4b-2500-4570-a94a-00eda0f022d1" />

# How do we use our reads to find information about our species genome?

## First, lets remind ourselves of some terminology

Can anyone tell me what genetic variation is in the most general sense?


<img width="1143" height="641" alt="Screenshot 2026-09-11 at 11 07 17 AM" src="https://github.com/user-attachments/assets/bb86447c-bd2d-4aaf-877b-eacc70bb5fd1" />


## What about a genotype?

## Why do we care?


<img width="1153" height="640" alt="Screenshot 2026-09-11 at 11 08 14 AM" src="https://github.com/user-attachments/assets/764e9204-188e-4f49-857d-8c80e18d9470" />

## How do we find variation?

<img width="520" height="336" alt="Screenshot 2026-09-11 at 11 10 59 AM" src="https://github.com/user-attachments/assets/4285a0dc-b324-4200-9c47-d08ff02588dc" />

## Some terminology about reads and read mapping:

<img width="839" height="477" alt="Screenshot 2026-09-11 at 11 11 52 AM" src="https://github.com/user-attachments/assets/77e4bf4e-0bcc-4ac1-a76c-b2697afc2cb9" />


## What is the general pipeline for mapping reads to a reference genome?


<img width="1281" height="713" alt="Screenshot 2026-09-11 at 11 09 29 AM" src="https://github.com/user-attachments/assets/37b35434-74e9-4264-a61a-5221ad92cafd" />


