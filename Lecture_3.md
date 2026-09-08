
# A brief refresher on files types

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

# What kind of flies did we catch?

<img width="289" height="372" alt="image" src="https://github.com/user-attachments/assets/f7df8527-39cc-4b50-9882-b70ae0f2fe82" />

Drosophila recens

<img width="413" height="493" alt="image" src="https://github.com/user-attachments/assets/2b6b5ac8-d52b-47ec-9ee1-e36420ea7711" />

Scaptomyza pallida

<img width="711" height="574" alt="image" src="https://github.com/user-attachments/assets/245dfe3d-0804-42e4-a599-b65734e86422" />

unidentified

<img width="437" height="262" alt="image" src="https://github.com/user-attachments/assets/04375b15-dc56-412a-8648-4bdc3a82079f" />

Drosophila algonquin

<img width="437" height="262" alt="image" src="https://github.com/user-attachments/assets/6cea8ed2-feaf-41c2-b4d9-0ee7784d16d8" />

Drosophila putrida

<img width="565" height="315" alt="image" src="https://github.com/user-attachments/assets/d73b2709-c776-4152-b655-15320da4df24" />

Drosophila hydei




