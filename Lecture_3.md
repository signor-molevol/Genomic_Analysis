# The Drosophila Genome nexus

<img width="592" height="307" alt="Screenshot 2026-09-08 at 2 27 12 PM" src="https://github.com/user-attachments/assets/7a543afc-2006-4cc2-9f7c-ac425045c823" />



Search in google scholar for the manuscript: A Thousand Fly Genomes: An Expanded Drosophila Genome Nexus

<img width="665" height="253" alt="Screenshot 2026-09-08 at 2 43 52 PM" src="https://github.com/user-attachments/assets/d6ddfb8c-babf-408c-8af6-8dc2b8430eb4" />

Click on the cited by link

Look for an interesting manuscript that used either this data or this type of data, and look it over briefly. Summarize the manuscript (very briefly, does not need to go into detail) and tell the class about it. 

An example: From sub-Saharan Africa to China: Evolutionary history and adaptation of Drosophila melanogaster revealed by population genomics

1. The authors found six distinct 'ancestry lineages' of Drosophila melanogaster, with China a distinct group
2. European and Chinese D. mel share a common ancestor around 9,000 years ago, then diverged around 2-4,000 years ago
3. D. mel reached Australia and North America around 200 years ago
4. Distribution of D. mel is tightly tied to human activity
5. They found selection at insecticide resistance loci

## Any question you ask will be smaller than these manuscripts, but you can start thinking about the type of question that these datasets can answer

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


# What kind of flies did we catch?

<img width="289" height="372" alt="image" src="https://github.com/user-attachments/assets/f7df8527-39cc-4b50-9882-b70ae0f2fe82" />

Drosophila recens

<img width="413" height="493" alt="image" src="https://github.com/user-attachments/assets/2b6b5ac8-d52b-47ec-9ee1-e36420ea7711" />

Scaptomyza pallida

<img width="711" height="574" alt="image" src="https://github.com/user-attachments/assets/245dfe3d-0804-42e4-a599-b65734e86422" />

unidentified

<img width="437" height="262" alt="image" src="https://github.com/user-attachments/assets/04375b15-dc56-412a-8648-4bdc3a82079f" />

Drosophila algonquin

<img width="422" height="416" alt="image" src="https://github.com/user-attachments/assets/21fe3d88-cf0a-4847-a623-d1507951112a" />

Drosophila putrida

<img width="565" height="315" alt="image" src="https://github.com/user-attachments/assets/d73b2709-c776-4152-b655-15320da4df24" />

Drosophila hydei


## What are we looking for? Mostly D. melanogaster and D. simulans
<img width="1484" height="1077" alt="image" src="https://github.com/user-attachments/assets/43043884-12a2-401a-86c8-107c5f057a9e" />

<img width="850" height="314" alt="image" src="https://github.com/user-attachments/assets/cf0988af-15c1-4cd7-9bcf-de985f770fe6" />


But....males don't lay eggs, so how do we identify the females?



<img width="4228" height="2816" alt="image" src="https://github.com/user-attachments/assets/ee4ba2d2-b56b-40da-bb33-325255d09218" />

You can't! So right now I have single females laying eggs, and we will see what emerges.

Then, I'm going to inbred them for a little bit. Can anyone guess why we inbred them before sequencing?





