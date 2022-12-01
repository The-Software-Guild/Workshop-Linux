# Wiley Edge Linux Workshop

- You can follow along with the docker compose app, or on AWS ec2 with a awslinux2 instance. Regardless, it is recommended to have a look at the aws docker compose app after the course. It contains everything you need to follow along on a linux container.

## Part 1 Processes and man

1. Print the 10th line of the file.  
`head -n10 file.txt | tail -n1`  
- Note: Head gets the top n number of lines, tail gets the last n number of lines. So we can simply get the last line after piping to tail

2. Write a script that prints any given line number of a file.
- The first arg should be the file name
- Second arg the line number
- When complete, we will review a suggested solution
- With the suggeted solution, how can we check if it ran successfully?
- `echo $?` will give us exit code of previous command, 0 is pass antything else is fail
- What is the purpose of the shift command in this script?

3. In linux, what are inodes (index nodes)?
- Unix systems have a database that every file name points to an inode number
- The inode number often is disk location to the inode, but the inode itself is a struct (like in C ) that contains information about each file. The informaiton may include file size, permissions, group, owner, and blocks. 
- The blocks are the actual memory locations the files are stored on, similar to arrays except the blocks do not have to be in order. When files are stored in blocks that are in non sequential memory locations, this is called fragmentation. 

4. Suppose in an interview you were asked to list the inode number of a file. Use the man command on ls to find how to print inode keys. Search for the word inode in the manual. Being able to find an answer to an interview question by quickly searching a manual is vital.  
`ls -i`

5. Print the inode information of any file in home folder.  
`stat READEME.md`

6. Start the logger.sh script. Send it to background (ctrl +z) , start it in background (bg 1), and send it to foreground again (fg 1). Use the jobs command in between each step.

7. Kill the process (ctrl +c if in foreground, or kill -9 PID if in background) and start it again with & so that it starts in background

8. Confirm it is running with ps and grep  
`ps -eaf | grep logger | grep -v grep` 
- Note: The second grep removes the first grep searching for the actual process!
- Note: Run `ps -eaf` without grep. Notice the parent process to the logger script is the current bash session. If you exit bash, all processes whos parent is bash will be terminated as well! 

9. Now save the PID in a variable named PID
`PID=$(ps -eaf | grep logger | grep -v grep | awk '{print $2')`
- what is awk doing here?
- Break the command down, run the first part, then add subsequent pipes one at a time.

10. What files are the process are writing to?
`lsof -p $PID | more`
or, for live view 
`sudo strace -f -t -e trace=file -p $PID`
You can even grep for the file access modes
`sudo strace -f -t -e trace=file -p $PID 2>&1 | egrep "O_WRONLY\|O_CREAT\|O_APPEND"`

11. Exit your termial session, log back in, and look for the process. Is is still there? How can we make it persist?   
- You can use nohub, or screen. Practice doing this, it is important for commands that need to be executed longer than your bash session (especially if you are having connectivity or timeout issues)
- If using screen just enter `screen`, start your process, detact with `ctrl + a then d`. Read the manual for screen and find out how to list screen sessions and attach to one


# Check Point

- We started with a simple script that helped us review best bash practices (args, defensive coding)
- We reviewed how to search a commands manual entry page. 
- Ran a simple script in the background and found out information about that process, including which files it has open.
- Exited the terminal and demonstrated that any child process of the bash process would be terminated. To keep this process running we used nohub or screen. Be careful not to keep child processes running longer than intended. 
- If you ever need to kill all child processes, run `kill $(ps -o pid= --ppid $$)`, where $$ is the current bash process and can be replaced with any PID

## Part 2 Advanced Commands

12. cd to `code` dir. Read the man for `dif`, search for large files, and use it to compare utils.py and app.py
- Note: git diff provides a better UX for comparing files, but will only be available if git is installed. The `comm` command is another alternative.
- Note: search for the `<` symbol in the manual to understand which file origined the line difference
`diff --speed-large-files utils.py app.py`

13. What lines of code are repeated in app.py?  
`uniq -d app.py`

14. In the code direcrory, list all files containing the WHOLE word `hello` (not words containing the string hello, such as nohello)  
- Note: Make sure you read the man for grep and options
`grep -lrw hello .`

15. Replace the word `hello`(and only the word WHOLE word hello) **to the word new** in the file util.py  
`sed 's/\bhello\b/new/g' util.py`  
- Read the manual for sed (stream editor)
- Note: You can redirect the output with `>`, or use the `-i` for inplace
- Now replace the word hello in EVERY file it occours, with one command
	- First, read the man for `xargs`
	- `grep -lrw hello . | xargs sed -i 's/\bhello\b/new/g'`

16. Intall a common web server, such as httpd, and start it. If on AWS, open port 80 (http) in AWS security group settings  
`sudo yum update`   
`sudo yum install httpd`  
`sudo systemctl start httpd`  
- Use `dig TXT +short o-o.myaddr.l.google.com @ns1.google.com` to get public ip address, read man on dig!
- Go to the ip address in browser

17. Now read the man page for `netstat`. Find out how to display listening ports. You should see port 80 (or http)  
`sudo netstat -lpn`  
- Stop httpd, then look at ports again
`sudo systemctl stop httpd`  
`netstat -lpn`
- If a server is running slow, you can use the `top` command to view the most computationally expensive processes


18. Network traffic
- If httpd is off, start it with ``sudo systemctl start httpd` `
- Lots of tools exists for network traffic, however, [RedHat recommends](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/sect-red_hat_enterprise_linux-performance_tuning_guide-networking-monitoring_and_diagnosing_performance_problems) `ss`. One nice feature of netstat is the `-c` continious option
`sudo netstat -ntcp`
`watch ss -mip`  
- Note: ss does not have the continous option like netstat, watch is useful but does not output to a file. The commands below display to standard output, and save to a file.
`echo "" > network.out; while true; do sleep 2; ss -mip >> network.out; tail -n5 network.out; done`
- What does the script above do with network.out?

19. Finding log files through strace and file descriptors
- Sometimes logs are written to file descriptors, like standard output (1) or standard error (2)
- When a process makes a system call to open a file, it recieves a file descriptor that persist until the file is closed
- The httpd web server maintains an open connection to the access_log file. We will use `xargs` and `strace` to find the file!  
`ps auxw | grep httpd | awk '{print"-p " $2}' | sudo xargs strace`
- Send a web request and look at the console. You should see a line that contains something similar to "write(8, "172.24.0.1 - - [25/Nov/2022:02:4"..., 194) = 194"
- The first argument to write is the file descriptor, which belongs to the PID within the brackets, lets suppose the PID is 145
- Obtain the file path of the file being written to with this `sudo ls -l /proc/145/fd`
- Just look for the path associated to the file descriptor written to to get the file path!


# Conclusion
- git diff is the best tool for comparing files, but diff or comm work great. If the file is large, make sure to set the correct flags
- xargs is a powerfull tool for sending multiple arguments to a command from standard input.
- sed, grep, and awk are essential tools for searching/manipulating streams
- netstat and ss are great for viewing network activity of processes, while strace can show you all the files processes are interacting with
- BONUS CHALLENGE: use grep -P (perl regular expressions) to write a regex that can verify a password is more than 8 characters, has a number, captial letter, lower case letter, and special cahracter. Perl regular expressions will help you stand out in iinterviews!
