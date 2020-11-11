#!/bin/bash

STUDENTS=$HOME/work/students

folder=$1
shift

if [[ -z "$folder" ]]
then
    echo "Usage: $0 <folder>"
    exit
fi

declare -a names
if [[ $# -gt 0 ]]
then
    for a in $@
    do
        names=(${names[@]} $STUDENTS/$a)
    done
else
    for a in $STUDENTS/*
    do
        names=(${names[@]} $a)
    done
fi

echo "Collecting $folder from ${#names[@]} students."
echo "Do you want to continue? (y/n)"
read answer

if [[ ! "$answer" == "y" ]]
then
    exit
fi

for a in "${names[@]}"
do
    student=$(basename $a)
    src=$a/$folder
    target=./$folder/$student
    if [[ -d $src ]]
    then
        echo "Collecting $src to $target"
        cp -r -T -u $src $target
    else
        echo "Missing $student/$folder"
    fi
done
