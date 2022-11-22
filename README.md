# Wiley Edge Linux Workshop

1. Print the 10th line of the file.  
`head -n10 test.txt | tail -n1`  
- Note: Head gets the top n number of lines, tail gets the last n number of lines. So we can simply get the last line after piping to tail

2. Write a script that prints any given line number of a file.
- The first arg should be the file name
- Second arg the line number
- When complete, we will review a suggested solution
    - With the suggeted solution, how can we check if it ran successfully?
    - `echo $?` will give us exit code of previous command, 0 is pass antything else is fail

3. In linux, what are inodes (index nodes)?
- Unix systms have a database that every file name points to an inode number
- The inode number often is disk location to the inode, but the inode itself is a struct (like in C ) that contains information about each file. The informaiton may include file size, permissions, group, owner, and blocks. 
- The blocks are the actual memory locations the files are stored on, similar to arrays except the blocks do not have to be in order. When files are stored in blocks that are in non sequential memory locations, this is called fragmentation. 

4. Suppose in an interview you were asked to list the inode number of a file. Use the man command on ls to find how to print inode keys. Search for the word inode in the manual. Being able to find an answer to an interview question will earn you bonus points for problem solving and resourcefullness.  
`ls -i`

5. Print the inode information of any file in home folder.  
`stat READEME.md`

6. Start the logger.sh script. Send it to background (ctrl +z) , start it in background (bg 1), and send it to foreground again (fg 1). Use the jobs command in between each step. Repeat if you did not use jobs in between each step.

7. Kill the process (ctrl +c if in foreground, or kill -9 PID if in background) and start it again with & so that it starts in background

8. Confirm it is running with ps and grep  
`ps -eaf | grep logger | grep -v grep` 
- Note: The second grep removes the first grep searching for the actual process!
- Note: Run `ps -eaf` without grep. Notice the parent process to the logger script is the current bash session. If you exit bash, all processes whos parent is bash will be terminated as well! 

9. Now save the PID in a variable named PID
`PID=$(ps -eaf | grep logger | grep -v grep | awk '{print $2')`
- what is awk doing here?

10. What files are the process are writing to?
`lsof -p $PID | more`
or, for live view 
`sudo strace -f -t -e trace=file -p $PID`
You can even grep for the file descriptors to only get files being appended to
`sudo strace -f -t -e trace=file -p 42 2>&1 | egrep "O_WRONLY\|O_CREAT\|O_APPEND"`

11. Exit your termial session, log back in, and look for the process. Is is still there? How can we make it persist?   
- You can use nohub, or screen. Practice doing this, it is important for commands that need to be executed longer than your bash session (especially if you are having connectivity or timeout issues)
- If using screen just enter `screen`, start your process, detact with `ctrl + a then d`. Read the manual for screen and find out how to list screen sessions and attach to one


# Conclusion

- We started with a simple script that helped us review best bash practices (args, defensive coding)
- We reviewed how to quickly ue the manual to find answers that you may be asked in intervies. Interviewers love to see your problem solving approach, and searching for text in a manual is a great asset in that situation.
- Ran a simple script in the background and found out information about that process, including which files it has open.
- Exited the terminal and demonstrated that any child process of the bash process would be terminated. To keep this process running we used nohub or screen. Be careful not to keep child processes running longer than intended. 
- If you ever need to kill all child processes, run `kill $(ps -o pid= --ppid $$)`, where $$ is the current bash process and can be replaced with any PID
