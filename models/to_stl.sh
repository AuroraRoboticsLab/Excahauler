#!/bin/sh
files="$1"
[ -z "$files" ] && files=`echo *.scad` 

for f in $files
do
	d=`echo $f | sed -e 's/[.]scad/.stl/'`
	echo "Converting $f to $d"
	openscad "$f" -o "$d" || exit 1
done

