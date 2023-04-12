#!/bin/bash

filedir=$1
searchstr=$2
#file match
X=0
#file match
Y=0

if [ "$1" == "" ] || [ "$2" == "" ]
then
	echo "Invalid insertion of directories. -> ./finder.sh <FILEDIR> <SEARCHDIR>"
	exit 1
fi

if [ ! -d "$filedir" ]
then
	echo "Directory does not exists. (${filedir}). Please use: ./finder.sh <FILEDIR> <SEARCHDIR>"
	exit 1
fi

for file in "$filedir"/*
do
	counter=$(grep -c $searchstr $file)
	echo "Find $file  ====>  matches: $counter"
	if [ $counter -gt 0 ]
	then
		((X=X+1))
	fi
	((Y=Y+counter))
done

#echo "Number of files: ${X}"
#echo "Number of lines: ${Y}"
echo "The number of files are ${X} and the number of matching lines are ${Y}"
