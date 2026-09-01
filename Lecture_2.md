# Log into the server

To sign into the server, type this:

```
ssh visitor@134.129.113.32
```
You will see this prompt for a password. Type in:

```
temp
```

## Navigate to /storehouse/visitor

What command should you use to list the available files in this directory?

Use this command to enter the directory called working_with_files/

What do you see in this directory? What command did you use?

# A reminder on the FASTQ format

| Line	| Description |
|-------|-------------|
| 1	| Always begins with ‘@’ and then information about the read |
| 2	| The actual DNA sequence|
| 3	| Always begins with a ‘+’ and sometimes the same info in line 1 |
| 4	| Has a string of characters which represent the quality (phred) scores; must have same number of characters as line 2 |


## The cp command

cp means copy, just like when you copy and paste something in word

In this case, we are making a copy of the whole file in a different directory

If I wanted to copy this file to my directory, I would use the following command:

```
cp SRR3585777.fastq ../dr_signor

```

Can you copy this file into your directory? 

Is this an absolute or a relative path?

Once you have it copied into your directory, navigate to your directory.

## Lets look at the beginning of this file

This file is 1.7 gb, a relatively small genomic dataset. You still probably don't want to try and open the whole file to interact with it. One way you can preview the file is with this command:

```
head
```

By default head shows the first 10 lines of a file. You can modify that with a flag, like:

```
head -20

```
Type in the following:

```
head SRR3585777.fastq

```

You should see this output:

```
@SRR3585777.1 HISEQ2500:113:C4K51ACXX:4:1101:3040:1961 length=110
AAACATATTTCACAAGAACATATTAAGTAAAGTATANNGAGGCCAAACCTANNGGCTCTAAATTATTATACCGCTACTCGTAGAGTAGACATGCAGATTATAGTGGCAAC
+SRR3585777.1 HISEQ2500:113:C4K51ACXX:4:1101:3040:1961 length=110
BBBFFFFFFFFFFFIIFFIIFFIIIIIFFFIFBFFF##0<BFFIIIIIIII##00BBFIFIFFIIIIIIFF<BFFFFBFFBBFFBBBBFFFFFFFFFFFFFFBBBBBBFF
@SRR3585777.2 HISEQ2500:113:C4K51ACXX:4:1101:4751:1968 length=110
GGAAACACTTCTCATTATGATTTAATCTCGTGGTAATCACTATCATAGTTTNNATTTTATTAACTCAGATTTTCTCCGAGTGTACGGTTGCACCCAGCAAGACGTTAATC
+SRR3585777.2 HISEQ2500:113:C4K51ACXX:4:1101:4751:1968 length=110
BBBFFFFFFFFFFFIIIIIIIIIIIIIIIIIIIFFIIIIIIIIIIIIIIII##07BFIIIIIIIIIIIIIIIIIIIIFFFBFFFFFFBBFFFFFFFFFFFFFFFBFFFFF
@SRR3585777.3 HISEQ2500:113:C4K51ACXX:4:1101:5116:1967 length=110
AACAGAACAAGTTCGAAATGAACATGTTCGAACAGAACATGTTCGAACAGANNATGTTCGAACAGAACATGTTCGAACAGAACATGTTCGAACAGAACATGTTCAAACAA
```

This is what a fastq file looks like - the header, starting with @, the sequence, the quality score header staring with +, and the quality string.

<img width="675" height="214" alt="image" src="https://github.com/user-attachments/assets/6ca55b45-4f3f-482c-98ed-1f0661e853e9" />

So these are mostly high quality reads, with a bit of variation down the length. 

# What is this data?

The Short Read Archive (SRA) is a database maintained by The National Center for Biotechnology Information (NCBI).
This is a government funded agency, and is where we all store sequencing reads to that they can be accessed by other people. It is generally a requirement for publication that your reads get deposited here. 

## Google short read archive

You should get a result that looks like this:

<img width="883" height="430" alt="Screenshot 2026-09-01 at 11 47 44 AM" src="https://github.com/user-attachments/assets/647f8e22-651d-43bd-9910-14a35b07e346" />

Click on that result. There should be a search bar at the top. Copy and paste the SRR ID from your fastq file (leave out the fastq portion) and search. 

What do you see?

This is a website you will likely spend some time on.

# Back to a little more code

## Wildcards

You can use commands like this:

```
ls *.fastq
```
to list every file that ends in fastq, and no other files. The * is a wildcard that will match anything before the '.'.

This command:
```
ls /usr/bin/*.sh
```

Lists everything in /usr/bin that ends in .sh.

```
/usr/bin/env_parallel.sh  /usr/bin/gettext.sh  /usr/bin/gvmap.sh  /usr/bin/nvidia-bug-report.sh  /usr/bin/nvidia-sleep.sh  /usr/bin/rescan-scsi-bus.sh
```

# Class Exercise 1
Do each of the following tasks from your current directory using a single ls command for each:

List all of the files in /usr/bin that start with the letter ‘c’.
List all of the files in /usr/bin that contain the letter ‘a’.
List all of the files in /usr/bin that end with the letter ‘o’.
Bonus: List all of the files in /usr/bin that contain the letter ‘a’ or the letter ‘c’.

Hint: The bonus question requires a Unix wildcard that we haven’t talked about yet. Try searching the internet for information about Unix wildcards to find what you need to solve the bonus problem.

## Getting out of a pickle

A very common occurrence is to type in a command, press enter, and have it hang without knowing why. You can escape this situation the following way: 

Ctrl+C will cancel the command you are writing, and give you a fresh prompt.

# Class Exercise 2
1. What is the last line of the SRR3585777.fastq? (you can google this)
2. What is the fourth line of SRR3585777.fastq?
   BONUS: How many reads are in this file (you can google how to do this)

# One last command

```
less
```

less is a great solution for viewing very large files, however know that you cannot edit files in less. try typing in the following command in your directory:

```
less SRR3585777.fastq
```

|key|	action|
-------------------
Space	to go forward
-------------------
b	to go backward
-------------------
g	to go to the beginning
-------------------
G	to go to the end
-------------------
q	to quit
-------------------
