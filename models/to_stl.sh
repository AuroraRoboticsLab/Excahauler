#!/bin/sh
files="$1"
[ -z "$files" ] && files=`echo *.scad` 

src="../Excahaul_latest.scad"

for f in $files
do
	d=`echo $f | sed -e 's/[.]scad/.stl/'`
	if [ ! -e "$d" -o \( "$f" -nt "$d" -o "$src" -nt "$d" \) ]
	then
		echo "Converting $f to $d"
		openscad --enable=manifold "$f" -o "$d" || exit 1
	fi
done

