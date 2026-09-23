## Document your code

## One of the easiest things to do is write it on github. 

## navigate to github.com

Username: SignorLab
passwd: genomicanalysis1&

Create a new file by pressing the plust sign. Call the file Table_*.md 

Replace the * with your table number

Remember the steps we took to process our file:

1. fastp
2. BWA index
3. BWA mem
4. samtools view
5. samtools sort


Three tick marks denotes code 

```
"````"
```

Two hashes makes a header. One hash makes a really big header. Leave a space after the hash. 

Write out the code that you used for each of these steps. For fastp, I did a lot of that. Try to write a for loop now
for fastp. Try to use for loops for every step except BWA index. 

For each step, write a header saying what you are doing. For example:

## Trimming adapters and quality filtering
```
for i in *.lite.1_1.fastq
do
OUT=${i%.lite.1_1.fastq}
fastp -i $OUT.lite.1_1.fastq etc. 
done
```

We can help you with anything you are confused about. Once you have everything written down, click the
button that says 'commit changes'. That way I can look over your code later. 


# Looking for ideas for Drosophila projects. 

1. Brainstorm something that interests you. Almost any topic has been looked at in Drosophila, and
sometimes there are documented phenotypes. The populations on our server are from Egypt, Ethiopia,
France, South Africa, and Zimbabwe. You are free to stick to these. You could do things like look at
a set of genes that interest you (i.e. Odorant receptors), or something with copy number variation.

For example, this paper is on copy number variation:

https://academic.oup.com/mbe/article/33/5/1308/2579856

You could look at phenotypes like pigmentation, wing size, etc. There may be information for some lines on
alcohol tolerance (actually there is, I can help with that). I encourage you to poke around and come
up with a few options.

## What data did they use?

Places to look: The data availability statement, supplemental files, or search the document for key words
SRA, Bioproject, etc. 

They data they used may not be appropriate for this work - for example I would discourage using pooled data. 

You also don't want to do exactly what they did. Look at what other people have done and fine a way to make
it smaller - you aren't writing a research paper - and put your own spin on it. 

Then you can ask, is there a way I can use different data to come at this question from a
different angle?

For example:

https://pubmed.ncbi.nlm.nih.gov/27777283/



In this paper cold adapted flies are from Ethiopia, and warm adapted flies are from France. We probably have at
least a subset of these flies.

Look at the supplemental information, they have phenotypes published for them.

One idea would be to look at some genes from this paper you think are interesting, then
compare to ND flies once we have the data. 

No problem if you guys want to look at this, but everyone has to look from a different angle -
two groups can't ask the same question.


Start poking around - Start a file with the following information:

1. Paper URL or name
2. Basic question
3. What data they used/what comparison
4. Is there phenotype information?
5. Possible direction your inquiry could take. 

Try to come up with two options before the end of class and send them to me. 
