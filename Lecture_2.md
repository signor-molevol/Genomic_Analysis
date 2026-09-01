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

# A reminder on the FASTQ format

| Line	| Description |
|-------|-------------|
| 1	| Always begins with ‘@’ and then information about the read |
| 2	| The actual DNA sequence|
| 3	| Always begins with a ‘+’ and sometimes the same info in line 1 |
| 4	| Has a string of characters which represent the quality (phred) scores; must have same number of characters as line 2 |

