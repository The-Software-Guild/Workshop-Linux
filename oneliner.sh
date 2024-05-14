#!/bin/bash

PROGNAME=$0

: "
$0 is always the program name
$# is the number of arguments
$@ is list of all arguments that can be iterated
$1 would be first argument, whereas $2 would be second ...

In this script we use the getopts to handle args, it provides a standard
for handling named arguments

This script also demonstrates defensive programming. Try running it with invalid args
"


# function for when things go wrong
usage() {
  cat << EOF >&2
	Usage: $PROGNAME [-f <file>] [-n <number>]
	-f <file>: The file to read the line from
 	-n <number>: The line number to print to standard output
EOF
  exit 1
}

# read in args
while getopts f:n: o; do
  case $o in
    (f) file=$OPTARG;;
    (n) number=$OPTARG;;
    (*) usage
  esac
done
shift "$((OPTIND - 1))"
# shift removes the arguments parsed by getopts
# If any args are left, they will start at $1

# test if file and number were set from args, if not explain usage
[[ ! $file || ! $number ]] && usage;

# make sure number is an integer
[[ ! $number =~ ^[0-9]+$ ]] && { echo "-n must be an integer"; exit 1; }

# make sure file exists
[[ ! -f "$file" ]] && { echo "file does not exists"; exit 1; }

# make sure the integer is within range of file line numbers
if (( $( cat $file | wc -l ) < $number )); then
	echo "Number is greater than line count of file"
	exit 1
fi

# do the task...
head $file -n$number | tail -n1
exit 0
