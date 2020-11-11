#
# Distributes a release to students
#

STUDENTS=$HOME/work/students
name=${PWD##*/}
cp_options=$CP_OPTIONS

if [[ -z "$cp_options" ]]
then
    cp_options="-n"
fi

src=./${name}_release
if [[ ! -d $src ]]
then
    echo "Cannot find: $src"
    exit
fi

declare -a students
if [[ $# -gt 0 ]]
then
    for a in $*
    do
        students=(${students[@]} $a)
    done
else
    for a in $STUDENTS/*
    do
        students=(${students[@]} $a)
    done
fi

echo "Distributing \"$src\" to ${#students[@]} students."
echo "Do you want to continue? (y/n)"
read answer

if [[ ! "$answer" == "y" ]]
then
    exit
fi

function dist {
    src=$1
    target=$2
    echo "$src ==> $target"
    cp -r -T $cp_options $src $target
}

for a in "${students[@]}"
do
    target=$a/$name
    if [[ ! -e $target ]]
    then
        dist $src $target
    else
        echo "Already exists: $target"
    fi
done
