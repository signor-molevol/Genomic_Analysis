# Working on the command line

## Accessing the command line

### On a mac, type terminal into spotlight and click on the result with a black box next to it

<img width="338" height="151" alt="image" src="https://github.com/user-attachments/assets/bfb9cad9-c205-4e09-be98-e619f03de180" />


### On a windows computer: Enable Windows Subsystem for Linux

Open the Start menu, search for "Turn Windows features on or off," and click on the corresponding result.

In the Windows Features dialog box that appears, scroll down and locate "Windows Subsystem for Linux.”

Check the box next to "Windows Subsystem for Linux" and click "OK.”

Choose Ubuntu as your linux system


# Once you have terminal open, you should see $
```
$
```

This is the command prompt. You type in commands telling the computer to do things from here. 

To sign into the server, type this:

```
ssh visitor@134.129.113.32
```
and press enter



<img width="604" height="398" alt="Screenshot 2026-08-30 at 10 20 45 AM" src="https://github.com/user-attachments/assets/dee71142-7147-49b9-921d-827663ca98b4" />


You will see this prompt for a password. Type in:

```
temp
```

You will not see any letters on the screen as you type, it will look like you are typing nothing. Press enter when you are done.

You should see this: 

```
Welcome to Ubuntu 24.10 (GNU/Linux 6.11.0-29-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun Aug 30 03:22:01 PM UTC 2026

  System load:              0.0
  Usage of /:               50.4% of 913.29GB
  Memory usage:             52%
  Swap usage:               0%
  Temperature:              65.0 C
  Processes:                1166
  Users logged in:          1
  IPv4 address for eno1np0: 134.129.113.23
  IPv6 address for eno1np0: 2001:4930:113:0:ae1f:6bff:fe79:2ef0

 * Canonical Workshop gives developers fast, composable, reproducible, and
   secure developer environments that are perfect for agentic workflows.

   https://ubuntu.com/workshop

32 updates can be applied immediately.
To see these additional updates run: apt list --upgradable


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
Your Ubuntu release is not supported anymore.
For upgrade information, please visit:
http://www.ubuntu.com/releaseendoflife

New release '26.04 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Sun Aug 30 15:00:35 2026 from 172.25.243.0
visitor@dolly:~$ 
```

visitor is your username and dolly is the name of the system


# Your first command

Type
```
$ pwd
```

Do you see:
```
visitor@dolly:~$ pwd
/home/visitor
```
## pwd means print working directory. The output is telling you where on the computer you are. 



## Your second command: cd

cd means change directory

Type
```
$ pwd /storehouse/visitor
```

Now your command prompt should look like this:

```
visitor@dolly:/storehouse/visitor$ 
```

Type pwd again:
```
$ pwd
```

You should see this:

```
/storehouse/visitor
```

One of the challenges people often have during this course is knowing where they are. You can always type

```
pwd
```
To find out where you are

and

```
cd /storehouse/visitor
```
To get back to the class directory

## Your third command: ls

ls means list

Type
```
$ ls
```
You should see the following:
```
dr_signor  file.txt genome_nexus
```

Look at the output, do you notice any difference between the different objects that are listed?


## your fourth command is: mkdir

This means make directory - you use it to make a new location in the file tree

Type the following:

```
$ mkdir your_name
```

Replace your_name with your actual name. Don't use capitals, spaces, or any other special characters

Now type

```
$ ls
```

What do you see? What color is the new directory?

Can you change locations to move inside your directory?

This is where you will work until we start group projects. 

## Absolute and relative paths

The cd command takes an argument which is a directory name. Directories can be specified using either a relative path or a full absolute path. The directories on the computer are arranged into a hierarchy. The full path tells you where a directory is in that hierarchy.

Type the following:
```
$ cd /storehouse/visitor
$ pwd
```

You should see:

```
/storehouse/visitor
```

This is the full name of your home directory. This tells me that I are in a directory called visitor. This directory sits inside a directory called storehouse which sits inside the very top directory in the hierarchy. The very top of the hierarchy is a directory called / which is usually referred to as the root directory. So, to summarize: visitor is a directory in storehouse which is a directory in /.

Now enter the following command:

```
$ cd /your_name
```

What happened?

Now type this:
```
$ cd your_name
```
The first uses the absolute path, giving the full address from the home directory. The second uses a relative path, giving only the address from the working directory. A full path always starts with a /. A relative path does not.

A relative path is like getting directions from someone on the street. They tell you to “go right at the stop sign, and then turn left on Main Street”. That works great if you’re standing there together, but not so well if you’re trying to tell someone how to get there from another country. A full path is like GPS coordinates. It tells you exactly where something is no matter where you are right now. 
Now navigate inside of your individual directory and run the command ‘ls’.

```
$ cd dr_signor
$ ls
```
The command should return nothing, because we haven't created any files yet!

## Shortcut: tab completion

Typing out file or directory names can waste a lot of time and it’s easy to make typing mistakes. Instead we can use tab complete as a shortcut. When you start typing out the name of a directory or file, then hit the Tab key, the shell will try to fill in the rest of the directory or file name.

Since we are already in the visitor directory type ‘cd dr’ and then hit tab:

It should autocomplete for you to
```
cd dr_signor
```
You can always use tab to autocomplete directory and file names, as long as the name is unique

# Now you are going to practice your commands

type the following into the command line:

```
cd /bashcrawl/entrance/
```

once you are there, type:

```
cat scroll
```

Play the game for a little while with your table mates
