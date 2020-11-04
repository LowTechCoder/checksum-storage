#!/bin/bash
#bash list_dirs.bash "$dir_input"
source include.bash
exit_if_args_not $# 1 "8374483837"

#args
dir_input=$(echo $1 | sed 's#/$##g')

#empty files
empty_this_file "$script_path/.rec_dir_list.tmp"
empty_this_file "$script_path/.tmp.tmp"

#exit checks
exit_if_dir_missing "$dir_input" "97446676786968"

cd "$dir_input/"
eval_this=$(echo "find . -type d ! -iname '$checksum_dir' $exclude_find")
#echo "$eval_this"

eval $eval_this | sed 's#^./##g' > "$script_path/.rec_dir_list.tmp"

exit_if_file_empty_or_missing "$script_path/.rec_dir_list.tmp" "3467899764334"