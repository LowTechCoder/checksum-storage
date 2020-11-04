#!/bin/bash
# bash validate_config_file.bash "$conf_file" "$script_path/good_config.conf"
source include.bash
exit_if_args_not $# 2 "2819773979"

#args
conf_file=$(echo $1 | sed 's#/$##g')
good_conf_file="$2"

#empty files
empty_this_file "$script_path/.tmp.tmp"
empty_this_file "$script_path/.current_configs.tmp"

#exit checks
exit_if_file_empty_or_missing "$conf_file" "2536075410"
exit_if_file_empty_or_missing "$good_conf_file" "2735660041"

clean_config_file "$conf_file" "$script_path/.current_configs.tmp" 

#look for duplicate lines
cat "$script_path/.current_configs.tmp" > "$script_path/.tmp.tmp"
dup_search1=$(cat "$script_path/.current_configs.tmp" | sort | uniq | wc -l)
dup_search2=$(cat "$script_path/.tmp.tmp" | sort | wc -l)
if [ "$dup_search1" != "$dup_search2" ]
then
    echo "error 2607351342: config file validation fail.  Name Duplicates found in config." >> "$script_path/recent.log"
    exit 1
fi

#look for invalid stuff
while IFS= read -r line
do
    line_search=$(get_line_from_uniq_file_list "$script_path/good_config.conf" "^$line.*")
    if [ "$line_search" == "false" ]
    then
        echo "error 1999702422: config file validation fail, exiting" >> "$script_path/recent.log"
        echo "$line" >> "$script_path/recent.log"
        exit 1
    fi
done < "$script_path/.current_configs.tmp"
