#!/bin/bash
# bash validate_config_files.bash "$mounts_dir" "$script_path/.drive_list.tmp" "$script_path/good_config.conf" "$conf_file"
source include.bash
exit_if_args_not $# 4 "68374483837"

#args
dir_input=$(echo $1 | sed 's#/$##g')
file_input="$2"
file_input2="$3"
conf_file="$4"

#empty files
empty_this_file "$script_path/.tmp.tmp"
empty_this_file "$script_path/.current_configs.tmp"

#exit checks
exit_if_dir_missing "$dir_input" "8765673332"
exit_if_file_empty_or_missing "$file_input" "3454343234322"

cd "$dir_input/"

#loop through drive list
while IFS= read -r drive
do
    exit_if_file_empty_or_missing "$drive/$conf_file" "6836357464353534"
    cat "$drive/$conf_file" >> "$script_path/.tmp.tmp"
done < "$file_input"

clean_config_file "$script_path/.tmp.tmp" "$script_path/.current_configs.tmp" 

#look for duplicate lines
cat "$script_path/.current_configs.tmp" > "$script_path/.tmp.tmp"
dup_search1=$(cat "$script_path/.current_configs.tmp" | sort | uniq | wc -l)
dup_search2=$(cat "$script_path/.tmp.tmp" | sort | wc -l)
if [ "$dup_search1" != "$dup_search2" ]
then
    echo "" >> "$script_path/recent.log"
    echo "ERROR 28575639587: config file validation fail.  Name Duplicates found in config." >> "$script_path/recent.log"
    exit 1
fi

#look for invalid stuff
while IFS= read -r line
do
    line_search=$(get_line_from_uniq_file_list "$script_path/good_config.conf" "^$line.*")
    if [ "$line_search" == "false" ]
    then
        echo "" >> "$script_path/recent.log"
        echo "ERROR 8674635959: config file validation fail." >> "$script_path/recent.log"
        echo "Invalid line found in config. Continuing pi_scripts_on_boot script, but skipping checksum_storage script." >> "$script_path/recent.log"
        echo "$line" >> "$script_path/recent.log"
        exit 1
    fi
done < "$script_path/.current_configs.tmp"
