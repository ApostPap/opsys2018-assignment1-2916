#!/bin/bash

file="$1";

function urlTest()
{
   line="$1"
    if [[ $line != *"#"* ]]
    then        
        name="${line//./_}";
        name="${name////_}";
        name="${name//:/_}";
        
        name="script1b/$name"
    
        #download page and rename output        
        wget -q "$line" -O "$name";
        result=$?;

        if [ $result == "0" ]
        then
             #check if downloaded before
             output=""$name"".md5"";

            if [ -e "${output}" ]
            then
                #check old and new md5
                if ! md5sum --status -c "$output";
                then
                   # echo "not the same"
                    echo "$line";
                fi

                #Update md5
                rm $output;
                md5sum -- "$name" > "${name}.md5"
                
            else
                #just create a md5 file from new
                md5sum -- "$name" > "${name}.md5"
                
                #check if failed before
                newfile=""$name""_fail"";
                if [ -e "${newfile}" ]
                then
                #failed before
                    echo "$line";
                    rm $newfile;
                else
                   #not failed before
                   echo "$line INIT";
                   
                fi

             fi

        else
        #FAILED
           
           
            #check if downloaded before

            output=""$name"".md5"";
            newfile=""$name""_fail"";
        
            if [ ! -e "${newfile}" ] 
            then
                #failed for the first time

                #create the new file
                touch $newfile;

                if [ -e "${output}" ]
                then
                    #fail on second time                
                    #remove old file
                    rm $output;
                    
                    echo "$line"

                else
                    #failed in first time
                    1>&2 echo "$line FAILED";
                fi
            fi
        fi

    fi
}


mkdir -p script1b/;


while IFS='' read -r line; do
   urlTest "$line" &

done < "$1"
wait $(jobs -p)
