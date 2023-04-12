#!/bin/bash
writefile=$1
writestd=$2

if [ "$1" == "" ] || [ "$2" == "" ]
then
	echo "Invalid insertion of directories. -> ./finder.sh <FILEDIR> <SEARCHDIR>"
	exit 1
fi

drct=$(dirname "$1")
filename=$(basename "$1")

if [ ! -d "$drct" ] ; then
	echo "Directory dont exists ===> creating"
	mkdir -p "$drct"
fi

echo "Directory exists ===> validating: $filename"

if [ -f $filename ] ; then
	echo "File exists => dump content"
	echo "$2" > $1
else
	echo "New file => dump content"
	touch $1
	echo "$2" > $1
fi


exit
mkdir drct

echo "Writing content on file"
echo $2 > $1/$1
