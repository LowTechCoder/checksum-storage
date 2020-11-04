#!/bin/bash
#bash get_drive_list_that_has_config.bash "$dir_input" "$file_output" 

source include.bash
exit_if_args_not $# 3 "1228412188"

#args
dir_input=$(echo $1 | sed 's#/$##g')
file_output="$2"
conf_file="$3"

#empty files
empty_this_file "$file_output"
empty_this_file "$script_path/.tmp.tmp"

#exit checks
exit_if_dir_missing "$dir_input" "913199275"

cd "$dir_input/"

find . -maxdepth 1 -type d ! -path . | sed 's#^./##g' | sort > "$script_path/.tmp.tmp"

while IFS= read -r drive
do
    #if config file exists
    if [ -r "$drive/$conf_file" ]
    then
        path=$(pwd)
        echo "$path/$drive" >> "$file_output"
    fi
done < "$script_path/.tmp.tmp"

exit_if_file_empty_or_missing "$file_output" "26593658"