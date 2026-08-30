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
