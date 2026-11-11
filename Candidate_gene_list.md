You will want to have a text file on the server with your candidate genes, one gene per line.

However, gene IDs can be very difficult to get right because they change and different files can use different conventions.

You can check your gene list here:

https://flybase.org/convert/id

Copy and paste it into the box, then look at the output for anything you need to fix. 

Then you will want to run gene_list_to_bed.py.

You can do this the following way:

make a file on the server.

```
nano gene_list_to_bed.py
```

Copy and past the text from the file on the github - gene_list_to_bed.py. Save and close.

To run:

```
python genes_list_to_bed.py /storehouse/visitor/reference/dmel-all-r6.69.gtf gene_list.txt genes.bed
```

Replacing gene_list.txt with your candidate gene list, and genes.bed with whatever you want your output to be. 
