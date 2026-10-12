# How to download from the SRA


## First create a text file of addresses. 

It could look something like this:

```
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115626/ERR16115626.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115627/ERR16115627.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115628/ERR16115628.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115629/ERR16115629.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115630/ERR16115630.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115631/ERR16115631.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115632/ERR16115632.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115633/ERR16115633.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115634/ERR16115634.lite.1
https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos10/sra-pub-zq-1002/ERR016/16115/ERR16115635/ERR16115635.lite.1

```


Then you would use a for loop that is a little different, the format is as follows:

```
while read p
do
done<file.txt
```

file.txt is your list of addresses

What you would put under 'do' is 

```
wget "$p"
```

Why do you think it needs to be in quotes?

try doing the following:

```
nano test.txt
```

inside test.txt, write:

```
echo file.txt
```

Now run the for loop from above once with the quotes and once without.

What happens?

Its because linux performs word splitting around quotes and any irregular values.

so, make one file that has all your addresses, and a second with your wget command.

Name the wget one something simple, like get_addresses.txt.

