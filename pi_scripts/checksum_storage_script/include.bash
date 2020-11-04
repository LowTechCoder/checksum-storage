#!/bin/bash
set -euo pipefail
# set -eu

#Globals
#It would be bad to change these after deployment.
script_path="$( cd "$(dirname "$0")" ; pwd -P )"

created_checksums="false"

parent_dir="checksum_storage"
conf_file="checksum_storage.conf"
checksum_dir=".checksum_storage"
verbose="true"
# exclude_find=$(printf "! -name %s " $(cat "$script_path/excludes.conf"))
# exclude_find=$(printf "! -name '%s' " $(cat "$script_path/excludes.conf"))

#build exclude list for find command
exclude_find=''
while read p; do
    exclude_find=$exclude_find$(printf " ! -iname '$p'")
done < "$script_path/excludes.conf"

# echo "exclude_find: $exclude_find"

#if script is on the pi
pi_search="/home/pi/pi_scripts"
if [[ "$script_path" == *"$pi_search"* ]]
then
    is_pi="true"
else
    is_pi="false"
fi

# exit_if_args_not $# 2 "58374483837"
exit_if_args_not () {
    if [ "$1" != "$2" ] 
    then 
        recent_log "ERROR $3, missing script argument, exiting"
        exit 1
    fi
}

# recent_log "$text_input"
recent_log () {
    # enableing this next line will cause the script to exit. Only use during debugging
    # echo "$1"
    exit_if_args_not $# 1 "122714650"
    echo "$1" >> "$script_path/recent.log"
}

# empty_this_file "$path/tofile.txt"
empty_this_file () {
    exit_if_args_not $# 1 "3865932620"
    echo -n "" > "$1"
}

# exit_if_dir_missing "$dir_input" "8465836"
exit_if_dir_missing () {
    exit_if_args_not $# 2 "884245314"
    if [ ! -d "$1" ] || [ ! -r "$1" ]; then
        recent_log "ERROR $2, dir doesn't exist, exiting"
        exit 1
    fi
}

# # exit_if_file_empty "$file_input" "8465836"
# exit_if_file_empty () {
#     exit_if_args_not $# 2 "80005130"
#     if [ ! -s "$1" ]
#     then
#         recent_log "ERROR $2, file doesn't exist, exiting"
#         exit 1
#     fi
# }

## exit_if_file_empty_or_missing "$arg_dir" "8465836"
exit_if_file_empty_or_missing () {
    exit_if_args_not $# 2 "1597965188"
    if [ ! -s "$1" ] || [ ! -r "$1" ]
    then
        recent_log "ERROR $2, file is empty or is missing, exiting"
        exit 1
    fi
}

# get_line_from_uniq_file_list "$file_input" "$line_search"
get_line_from_uniq_file_list () {
    exit_if_args_not $# 2 "770526910"
    exit_if_file_empty_or_missing "$1" "1234567890"
    line_found=$(cat "$1" | grep "$2")
    if [ -z "$line_found" ]
    then
        echo "false"
    else
        echo "$line_found"
    fi
}

# get_value_from_custom_arr "$value_input" "$name"
# get_value_from_custom_arr () {
#     exit_if_args_not $# 2 "337755443"
#     echo "$1" | sed 's#^#,#g' | sed 's#$#,#g' | sed -e "s#.*$2=\([^,]*,\).*#\1#" | sed 's#,##g'
# }

# create_checksum_exit "$message" "332234899" "$file"
create_checksum_exit () {
    exit_if_args_not $# 3 "337755443"
    recent_log "ERROR $2, $1"
    path=$(pwd)
    recent_log "$path/$3"
    exit 1
}

# exit_if_file_not_readable "$file_input" "58374483837"
exit_if_file_not_readable () {
    exit_if_args_not $# 2 "75638294746"
    path=$(pwd)
    if [ ! -r "$1" ]
    then
        recent_log "ERROR $2, file is not readable"
        recent_log "$path/$1"
        exit 1
    fi
}

# exit_now "58374483837" "$message"
exit_now () {
    exit_if_args_not $# 2 "7463858367"
    recent_log "ERROR $1, $2"
    exit 1
}

# finish_log $source_path
finish_log () {
    exit_if_args_not $# 1 "941054177"
    source_path="$1"
    recent_log ""
    df -H >> "$script_path/recent.log"
    secs=$SECONDS
    recent_log ""
    printf 'total time: %dh:%dm:%ds\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) >> "$script_path/recent.log"
    if [ -r "$source_path" ] && [ "$source_path" != "false" ]
    then
        cat "$script_path/verbose.log" > "$source_path/logs/checksum_storage_verbose.log"
        recent_log ""
        recent_log "finished checksum_storage main script"
        cat "$script_path/recent.log" > "$source_path/logs/checksum_storage_recent.log"
    fi
}

# finish_log_n_exit "3460323062" "$message" $source_path
finish_log_n_exit () {
    exit_if_args_not $# 3 "2547716777"
    recent_log "ERROR $1, $2"
    finish_log "$3"
    exit 1
}

# verbose_log "$text_input"
verbose_log () {
    exit_if_args_not $# 1 "799601193"
    if [ "$verbose" == "true" ]
    then
        # echo "$1"
        echo "$1" >> "$script_path/verbose.log"
    fi
}

# clean_config_file "$file_input" "$file_output" 
clean_config_file () {
    exit_if_args_not $# 2 "6794635578"
    file_input="$1"
    file_output="$2"
    #trim extra spaces or tabs
    #remove lines that start with #
    #remove empty lines
    cat "$file_input" | awk '{$1=$1};1'| sed 's/^#.*$//g' | \
        grep -v '^$'  > "$file_output"
}

# echo_to_file "$text_input" "$file_output"
# echo_to_file () {
#     exit_if_args_not $# 2 "34665432"
#     text_input="$1"
#     file_output="$2"
#     echo $text_input >> "$file_output"
# }

# my_time
elapsed_time () {
    secs2=$SECONDS
    secs3=$(($secs2-$secs1))
    secs=$secs3
    # printf '%dh:%dm:%ds\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) >> "$script_path/recent.log"
    printf '%dh:%dm:%ds\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
    secs1=$SECONDS
}


#bash command $text_input $file_input
get_config_line_in_file () {
    exit_if_args_not $# 2 "2933922179"
    text_input="$1"
    file_input="$2"
    # search for line, or return false
    search_line=$(cat "$file_input" | grep "$text_input" || echo "false")
    #if this config has the search pattern, then return the full path of this config
    if [ "$search_line" != "false" ]
    then
        the_return="$search_line"
    else
        the_return="false"
    fi
    echo "$the_return"
}


#bash get_config_file_path $input_search_text $input_path_list $conf_file
get_config_file_path () {
    exit_if_args_not $# 3 "3865932620"
    input_search_text="$1"
    input_path_list="$2"
    conf_file="$3"
    final_search=""
    #loop through the configs
    while IFS= read -r drive_path
    do
        #clean config file up first
        empty_this_file "$script_path/.tmp.tmp"
        clean_config_file "$drive_path/$conf_file" "$script_path/.tmp.tmp" 
        search_line=$(cat "$script_path/.tmp.tmp" | grep "$input_search_text")
        #if this config has the search pattern, then return the full path of this config
        if [ ! -z "$search_line" ]
        then
            final_search=$(echo "$drive_path/$conf_file")
        fi
    done < "$input_path_list"
    
    if [ -z "$final_search" ]
    then
        final_search="false"
    fi
    echo "$final_search"
}


# get_value_from_line $line_search"
get_value_from_line () {
    exit_if_args_not $# 1 "770526910"
    value=$(echo "$1" | sed 's#^.*=##g')
    if [ -z "$value" ]
    then
        echo "false"
    else
        echo "$value"
    fi
}

# get_value_from_source $line_search"
get_value_from_config () {
    exit_if_args_not $# 2 "770526910"
    file_input="$1"
    text_input="$2"

    config_line=$(get_config_line_in_file "$text_input" "$file_input") || \
        skip_sub_script_func "454116991" "bad get_config_line_in_file"

    valtest=$(get_value_from_line "$config_line") || \
        skip_sub_script_func "1815933709" "bad get_value_from_line"
    echo "$valtest"
}

# get_drive_from_config_path $input_path" $conf_file
get_drive_from_config_path () {
    exit_if_args_not $# 2 "770526910"
    input_path="$1"
    conf_file="$2"
    drive=$(echo "$input_path" | sed "s#$conf_file##g" | sed 's#/$##g')
    drive=$(echo "$drive" | awk -F "/" '{print $NF}')
    echo "$drive"
}