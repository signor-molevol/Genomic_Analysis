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


<img width="1153" height="640" alt="Screenshot 2026-09-11 at 11 08 14 AM" src="https://github.com/user-attachments/assets/764e9204-188e-4f49-857d-8c80e18d9470" />

## How do we find variation?

<img width="520" height="336" alt="Screenshot 2026-09-11 at 11 10 59 AM" src="https://github.com/user-attachments/assets/4285a0dc-b324-4200-9c47-d08ff02588dc" />

## Some terminology about reads and read mapping:

<img width="839" height="477" alt="Screenshot 2026-09-11 at 11 11 52 AM" src="https://github.com/user-attachments/assets/77e4bf4e-0bcc-4ac1-a76c-b2697afc2cb9" />


## What is the general pipeline for mapping reads to a reference genome?


<img width="1281" height="713" alt="Screenshot 2026-09-11 at 11 09 29 AM" src="https://github.com/user-attachments/assets/37b35434-74e9-4264-a61a-5221ad92cafd" />



## Do you remember when we learned about illumina sequencing, you had to glue a sequence to your DNA to get it to bind to the flow cell. Thats called an adapter. The first thing you have to do is filter your data for adapter sequences, low quality, etc. 


We do that with a program called fastp. 

Type in fastp and hit enter. Look at the output. 


````
fastp: an ultra-fast all-in-one FASTQ preprocessor
version 0.23.4
usage: fastp [options] ... 
options:
  -i, --in1                            read1 input file name (string [=])
  -o, --out1                           read1 output file name (string [=])
  -I, --in2                            read2 input file name (string [=])
  -O, --out2                           read2 output file name (string [=])
      --unpaired1                      for PE input, if read1 passed QC but read2 not, it will be written to unpaired1. Default is to discard it. (string [=])
      --unpaired2                      for PE input, if read2 passed QC but read1 not, it will be written to unpaired2. If --unpaired2 is same as --unpaired1 (default mode), both unpaired reads will be written to this same file. (string [=])
      --overlapped_out                 for each read pair, output the overlapped region if it has no any mismatched base. (string [=])
      --failed_out                     specify the file to store reads that cannot pass the filters. (string [=])
  -m, --merge                          for paired-end input, merge each pair of reads into a single read if they are overlapped. The merged reads will be written to the file given by --merged_out, the unmerged reads will be written to the files specified by --out1 and --out2. The merging mode is disabled by default.
      --merged_out                     in the merging mode, specify the file name to store merged output, or specify --stdout to stream the merged output (string [=])
      --include_unmerged               in the merging mode, write the unmerged or unpaired reads to the file specified by --merge. Disabled by default.
  -6, --phred64                        indicate the input is using phred64 scoring (it'll be converted to phred33, so the output will still be phred33)
  -z, --compression                    compression level for gzip output (1 ~ 9). 1 is fastest, 9 is smallest, default is 4. (int [=4])
      --stdin                          input from STDIN. If the STDIN is interleaved paired-end FASTQ, please also add --interleaved_in.
      --stdout                         stream passing-filters reads to STDOUT. This option will result in interleaved FASTQ output for paired-end output. Disabled by default.
      --interleaved_in                 indicate that <in1> is an interleaved FASTQ which contains both read1 and read2. Disabled by default.
      --reads_to_process               specify how many reads/pairs to be processed. Default 0 means process all reads. (int [=0])
      --dont_overwrite                 don't overwrite existing files. Overwritting is allowed by default.
      --fix_mgi_id                     the MGI FASTQ ID format is not compatible with many BAM operation tools, enable this option to fix it.
  -V, --verbose                        output verbose log information (i.e. when every 1M reads are processed).
  -A, --disable_adapter_trimming       adapter trimming is enabled by default. If this option is specified, adapter trimming is disabled
  -a, --adapter_sequence               the adapter for read1. For SE data, if not specified, the adapter will be auto-detected. For PE data, this is used if R1/R2 are found not overlapped. (string [=auto])
      --adapter_sequence_r2            the adapter for read2 (PE data only). This is used if R1/R2 are found not overlapped. If not specified, it will be the same as <adapter_sequence> (string [=auto])
      --adapter_fasta                  specify a FASTA file to trim both read1 and read2 (if PE) by all the sequences in this FASTA file (string [=])
      --detect_adapter_for_pe          by default, the auto-detection for adapter is for SE data input only, turn on this option to enable it for PE data.
  -f, --trim_front1                    trimming how many bases in front for read1, default is 0 (int [=0])
  -t, --trim_tail1                     trimming how many bases in tail for read1, default is 0 (int [=0])
  -b, --max_len1                       if read1 is longer than max_len1, then trim read1 at its tail to make it as long as max_len1. Default 0 means no limitation (int [=0])
  -F, --trim_front2                    trimming how many bases in front for read2. If it's not specified, it will follow read1's settings (int [=0])
  -T, --trim_tail2                     trimming how many bases in tail for read2. If it's not specified, it will follow read1's settings (int [=0])
  -B, --max_len2                       if read2 is longer than max_len2, then trim read2 at its tail to make it as long as max_len2. Default 0 means no limitation. If it's not specified, it will follow read1's settings (int [=0])
  -D, --dedup                          enable deduplication to drop the duplicated reads/pairs
      --dup_calc_accuracy              accuracy level to calculate duplication (1~6), higher level uses more memory (1G, 2G, 4G, 8G, 16G, 24G). Default 1 for no-dedup mode, and 3 for dedup mode. (int [=0])
      --dont_eval_duplication          don't evaluate duplication rate to save time and use less memory.
  -g, --trim_poly_g                    force polyG tail trimming, by default trimming is automatically enabled for Illumina NextSeq/NovaSeq data
      --poly_g_min_len                 the minimum length to detect polyG in the read tail. 10 by default. (int [=10])
  -G, --disable_trim_poly_g            disable polyG tail trimming, by default trimming is automatically enabled for Illumina NextSeq/NovaSeq data
  -x, --trim_poly_x                    enable polyX trimming in 3' ends.
      --poly_x_min_len                 the minimum length to detect polyX in the read tail. 10 by default. (int [=10])
  -5, --cut_front                      move a sliding window from front (5') to tail, drop the bases in the window if its mean quality < threshold, stop otherwise.
  -3, --cut_tail                       move a sliding window from tail (3') to front, drop the bases in the window if its mean quality < threshold, stop otherwise.
  -r, --cut_right                      move a sliding window from front to tail, if meet one window with mean quality < threshold, drop the bases in the window and the right part, and then stop.
  -W, --cut_window_size                the window size option shared by cut_front, cut_tail or cut_sliding. Range: 1~1000, default: 4 (int [=4])
  -M, --cut_mean_quality               the mean quality requirement option shared by cut_front, cut_tail or cut_sliding. Range: 1~36 default: 20 (Q20) (int [=20])
      --cut_front_window_size          the window size option of cut_front, default to cut_window_size if not specified (int [=4])
      --cut_front_mean_quality         the mean quality requirement option for cut_front, default to cut_mean_quality if not specified (int [=20])
      --cut_tail_window_size           the window size option of cut_tail, default to cut_window_size if not specified (int [=4])
      --cut_tail_mean_quality          the mean quality requirement option for cut_tail, default to cut_mean_quality if not specified (int [=20])
      --cut_right_window_size          the window size option of cut_right, default to cut_window_size if not specified (int [=4])
      --cut_right_mean_quality         the mean quality requirement option for cut_right, default to cut_mean_quality if not specified (int [=20])
  -Q, --disable_quality_filtering      quality filtering is enabled by default. If this option is specified, quality filtering is disabled
  -q, --qualified_quality_phred        the quality value that a base is qualified. Default 15 means phred quality >=Q15 is qualified. (int [=15])
  -u, --unqualified_percent_limit      how many percents of bases are allowed to be unqualified (0~100). Default 40 means 40% (int [=40])
  -n, --n_base_limit                   if one read's number of N base is >n_base_limit, then this read/pair is discarded. Default is 5 (int [=5])
  -e, --average_qual                   if one read's average quality score <avg_qual, then this read/pair is discarded. Default 0 means no requirement (int [=0])
  -L, --disable_length_filtering       length filtering is enabled by default. If this option is specified, length filtering is disabled
  -l, --length_required                reads shorter than length_required will be discarded, default is 15. (int [=15])
      --length_limit                   reads longer than length_limit will be discarded, default 0 means no limitation. (int [=0])
  -y, --low_complexity_filter          enable low complexity filter. The complexity is defined as the percentage of base that is different from its next base (base[i] != base[i+1]).
  -Y, --complexity_threshold           the threshold for low complexity filter (0~100). Default is 30, which means 30% complexity is required. (int [=30])
      --filter_by_index1               specify a file contains a list of barcodes of index1 to be filtered out, one barcode per line (string [=])
      --filter_by_index2               specify a file contains a list of barcodes of index2 to be filtered out, one barcode per line (string [=])
      --filter_by_index_threshold      the allowed difference of index barcode for index filtering, default 0 means completely identical. (int [=0])
  -c, --correction                     enable base correction in overlapped regions (only for PE data), default is disabled
      --overlap_len_require            the minimum length to detect overlapped region of PE reads. This will affect overlap analysis based PE merge, adapter trimming and correction. 30 by default. (int [=30])
      --overlap_diff_limit             the maximum number of mismatched bases to detect overlapped region of PE reads. This will affect overlap analysis based PE merge, adapter trimming and correction. 5 by default. (int [=5])
      --overlap_diff_percent_limit     the maximum percentage of mismatched bases to detect overlapped region of PE reads. This will affect overlap analysis based PE merge, adapter trimming and correction. Default 20 means 20%. (int [=20])
  -U, --umi                            enable unique molecular identifier (UMI) preprocessing
      --umi_loc                        specify the location of UMI, can be (index1/index2/read1/read2/per_index/per_read, default is none (string [=])
      --umi_len                        if the UMI is in read1/read2, its length should be provided (int [=0])
      --umi_prefix                     if specified, an underline will be used to connect prefix and UMI (i.e. prefix=UMI, UMI=AATTCG, final=UMI_AATTCG). No prefix by default (string [=])
      --umi_skip                       if the UMI is in read1/read2, fastp can skip several bases following UMI, default is 0 (int [=0])
      --umi_delim                      delimiter to use between the read name and the UMI, default is : (string [=:])
  -p, --overrepresentation_analysis    enable overrepresented sequence analysis.
  -P, --overrepresentation_sampling    one in (--overrepresentation_sampling) reads will be computed for overrepresentation analysis (1~10000), smaller is slower, default is 20. (int [=20])
  -j, --json                           the json format report file name (string [=fastp.json])
  -h, --html                           the html format report file name (string [=fastp.html])
  -R, --report_title                   should be quoted with ' or ", default is "fastp report" (string [=fastp report])
  -w, --thread                         worker thread number, default is 3 (int [=3])
  -s, --split                          split output by limiting total split file number with this option (2~999), a sequential number prefix will be added to output name ( 0001.out.fq, 0002.out.fq...), disabled by default (int [=0])
  -S, --split_by_lines                 split output by limiting lines of each file with this option(>=1000), a sequential number prefix will be added to output name ( 0001.out.fq, 0002.out.fq...), disabled by default (long [=0])
  -d, --split_prefix_digits            the digits for the sequential number padding (1~10), default is 4, so the filename will be padded as 0001.xxx, 0 to disable padding (int [=4])
      --cut_by_quality5                DEPRECATED, use --cut_front instead.
      --cut_by_quality3                DEPRECATED, use --cut_tail instead.
      --cut_by_quality_aggressive      DEPRECATED, use --cut_right instead.
      --discard_unmerged               DEPRECATED, no effect now, see the introduction for merging.
  -?, --help                           print this message

Citation:
Shifu Chen. 2023. Ultrafast one-pass FASTQ data preprocessing, quality control, and deduplication using fastp. iMeta 2: e107
```

Most of these options you will never use, unless you are working with unique data. These days many things are done automatically.

What you really need to see are the input and output flags.
```
-i (single end input)
-o (single end output)

## Try to write up a line of code to run on the fastq file in your directory.

## Did it work? What does your output look like?
