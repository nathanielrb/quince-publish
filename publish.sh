#!/bin/bash

## Parameters

here=`pwd`

project=$here/$1

name=`basename $1`

collection=`dirname $project`

out=$project/dist

mkdir -p $out

tmp=`mktemp -d`

files=`[ -f $project/files.conf ] && cat $project/files.conf || echo "$project/*.md"`

metadatafiles=`awk 'FNR==1&&NR!=1{print ""}1' $project/_book.yml $collection/_books.yml`

metadata="---\n$metadatafiles\n---\n"

content=`awk 'FNR==1&&NR!=1{print ""}1' $files`

cover=$project/cover.jpg

stylesheet=$collection/epub.css

full="$metadata$content"

latextemplate=`[ -f $collection/_templates/template.tex ] && echo "$collection/_templates/template.tex" || echo $here/template.tex`



## Run

echo "Using template:"
echo $latextemplate

cd $tmp

echo -e "$full" | pandoc -R --chapters --template $latextemplate -f markdown+hard_line_breaks --filter pandoc-latex-environment -o $name.tex -

echo -e "$full" | pandoc -R --chapters --template $latextemplate -f markdown+hard_line_breaks --filter pandoc-latex-environment -o $name.pdf -

echo -e "$full" | pandoc -R --chapters -f markdown+hard_line_breaks -o $name.epub --epub-cover-image=$cover --epub-stylesheet=$stylesheet -



## Copy Files

echo -e "$full" > $out/full.md

cp $name.tex $out/$name.tex

cp $name.pdf $out/$name.pdf

cp $name.epub $out/$name.epub



# Commit Changes

cd $out

git add $name.*

date=`date +%Y-%m-%d:%H:%M:%S`
git commit -a -m "Published in Quince, $date"



# Clean Up

cd $here
