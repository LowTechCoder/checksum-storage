#!/bin/bash
#bash checksums_file_scan.bash "$dir_input" "$config_name"
source include.bash
exit_if_args_not $# 2 "18374483837"

# #args
dir_input=$(echo $1 | sed 's#/$##g')
config_name=$2

# #exit checks
exit_if_dir_missing "$dir_input" "26345473875"

cd "$dir_input"
verbose_log ""
verbose_log "  --  start checksum scan  --"
verbose_log "on: name=$config_name"
verbose_log "in directory:"
verbose_log "$dir_input/"

compare_file_n_checksum () {
    dir_input="$4"
    script_path="$3"
    checksum_dir="$2"

    path_n_file="$1"
    #only show file from path and file
    file=$(basename "$path_n_file")
    #only show path from path and file
    path=$(dirname "$path_n_file")
    path2=$(echo "$path" | sed 's#^./##g')
    # echo "dir_slash_path: $dir_input/$path2"
    cd "$dir_input/$path2"
    if [ -f "$checksum_dir/$file.checksum" ]
    then
        checksum_orig=$(cat "$checksum_dir/$file.checksum")
        checksum_file=$(shasum -a 1 "$file") || create_checksum_exit "couldn't create checksum for scan, exiting" "514337600" "$file"
        if [ "$checksum_file" == "$checksum_orig" ]
        then
            echo "checksum scan good: $path2/$file" >> "$script_path/verbose.log"
        else
            echo "ERROR: checksum scan problem: $path2/$file" >> "$script_path/recent.log"
        fi

    fi
}
eval_this=$(echo "find . -type f ! -path . ! -name '.file_list.tmp' ! -name '*.checksum' ! -iname '$checksum_dir' $exclude_find")
eval $eval_this > "$script_path/.tmp.tmp"

# #looping through all files from .tmp.tmp
while IFS= read -r line
do
    compare_file_n_checksum "$line" "$checksum_dir" "$script_path" "$dir_input"
done < "$script_path/.tmp.tmp"



verbose_log ""
verbose_log "  --  checksum scan complete  --"