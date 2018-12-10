#!/bin/bash

function loopBig()
{
    sub_dirs=0
    sub_dir_name=""
    outer_other=0
    outer_txt=0
    outer_txt_name=""
    inner_other=0
    inner_txt=0
    inner_txt_name1=""
    inner_txt_name2=""

    for i in "$1"/*
    do
        if [ -f "$i" ]; then
            #Find .TXT FILE
            if [ ${i: -4} == ".txt" ]; then
                outer_txt=$((outer_txt+1))
                outer_txt_name="$(basename $i)"
            else
                outer_other=$((outer_other+1))
            fi

        else
           
            sub_dir_name="$(basename $i)"
            loopSubDir "$i"
            sub_dirs=$((sub_dirs+1))
            
        fi
    done
}


function loopSubDir() 
{
    for i in "$1"/*
    do
        if [ -d "$i" ]; then
            loopSubDir "$i"
            sub_dirs=$((sub_dirs+1))

        elif [ -e "$i" ]; then
            #Find .TXT FILE
            if [ ${i: -4} == ".txt" ]; then
                inner_txt=$((inner_txt+1))
                
                if [ $inner_txt -eq 1 ];
                then
                    inner_txt_name1="$(basename $i)"
                else
                    inner_txt_name2="$(basename $i)"
                fi

            else
                inner_other=$((inner_other+1))
            fi
        fi
    done
}

function findGits()
{
    for i in "$1"/*
        do
            if [ -d "$i" ]; then
                findGits "$i"
            elif [ -e "$i" ]; then
                # Find .TXT FILE
                if [ ${i: -4} == ".txt" ]; then
                    readGitAndClone "$i"
                fi
            fi
        done
}

function readGitAndClone()
{

    file="$1";
    while IFS='' read -r line; do
        if [[ $line == "https"* ]]
        then
            dirName=$(basename -- "$line")
            dirName="${dirName%.*}"
            git clone --quiet "$line" "assignments/$dirName";
            result=$?;
            if [ $result = "0" ]
            then
                echo "$line: Cloning OK"
            else
                1>&2 echo "$line: Cloning FAILED"
            fi
            break
        fi
        done < "$file"
}


#Make dir to extract to
mkdir -p extracted/;
#Extract file
compressed="$1";
tar -xzf "$compressed" -C extracted/;

#Make dir assignments
mkdir -p assignments/;
rm -rf assignments/*

findGits "extracted"

#Delete extracted files
rm -rf extracted


    for i in "assignments"/*
        do
            if [ -d "$i" ]; then
                
                echo "$(basename "$i:" ) "
                loopBig "$i"

                sumTxt=$((outer_txt + inner_txt))
                sumOther=$((outer_other + inner_other))
                echo "Number of directories: $sub_dirs"
                echo "Number of txt files: $sumTxt"
                echo "Number of other files: $sumOther"  

                if [ $sub_dirs -eq 1 ] && [ $outer_txt -eq 1 ] && [ $outer_other -eq 0 ] && [ $inner_txt -eq 2 ] && [ $inner_other -eq 0 ];
                then
                    
                    if [ $sub_dir_name == "more" ] && [ $outer_txt_name == "dataA.txt" ] && [ $inner_txt_name1 == "dataB.txt" ] && [ $inner_txt_name2 == "dataC.txt" ];
                    then
                        echo "Directory structure is OK"
                    else
                        1>&2 echo "Directory structure is NOT OK"
                    fi

                else
                    1>&2 echo "Directory structure is NOT OK"
                fi

            fi
        done