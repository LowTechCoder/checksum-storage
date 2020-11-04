#!/bin/bash
#bash _main.bash
#scripts should follow this format:
#bash command $input $output $arg1 $arg2

#Globals
#It would be bad to change these after deployment.
script_path="$( cd "$(dirname "$0")" ; pwd -P )"
#if script is on the pi
pi_search="/home/pi/pi_scripts"
if [[ "$script_path" == *"$pi_search"* ]]
then
    mounts_dir="/media/pi/"
    is_pi="true"
else
    mounts_dir="/Users/matt/Downloads/_super_backup_mounts/"
    # mounts_dir="/Volumes"
    is_pi="false"
fi
mounts_dir=$(echo $mounts_dir | sed 's#/$##g')

parent_dir="checksum_storage"
checksum_dir=".checksum_storage"

#build exclude list for find command
exclude_find=''
while read p; do
    exclude_find=$exclude_find$(printf " ! -iname '$p'")
done < "$script_path/excludes.conf"

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

# empty_this_file "$path/tofile.txt"
empty_this_file () {
    exit_if_args_not $# 1 "3865932620"
    echo -n "" > "$1"
}

# exit_if_dir_missing "$dir_input" "8465836"
exit_if_dir_missing () {
    exit_if_args_not $# 2 "884245314"
    if [ ! -d "$1" ] || [ ! -r "$1" ]; then
        echo "error $2, dir doesn't exist, exiting" >> "$script_path/recent.log"
        exit 1
    fi
}

## exit_if_file_empty_or_missing "$arg_dir" "8465836"
exit_if_file_empty_or_missing () {
    exit_if_args_not $# 2 "1597965188"
    if [ ! -s "$1" ] || [ ! -r "$1" ]
    then
        echo "error $2, file is empty or is missing, exiting" >> "$script_path/recent.log"
        exit 1
    fi
}

# exit_if_args_not $# 2 "58374483837"
exit_if_args_not () {
    if [ "$1" != "$2" ] 
    then 
        echo "error $3, missing script argument, exiting" >> "$script_path/recent.log"
        exit 1
    fi
}

# exit_now "58374483837" "$message"
exit_now () {
    exit_if_args_not $# 2 "7463858367"
    echo "error $1, $2" >> "$script_path/recent.log"
    exit 1
}

# skip_checksum_storage_script_func "58374483837" "$message"
skip_checksum_storage_script_func () {
    exit_if_args_not $# 2 "7463858367"
    skip_checksum_storage_script="true"
    echo "error $1, $2" >> "$script_path/recent.log"
}

# empty_this_file "$path/tofile.txt"
empty_this_file () {
    exit_if_args_not $# 1 "3865932620"
    echo -n "" > "$1"
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
        skip_on_error "454116991" "bad get_config_line_in_file"

    valtest=$(get_value_from_line "$config_line") || \
        skip_on_error "1815933709" "bad get_value_from_line"
    echo "$valtest"
}

# get_uniq_config_file $dir_input $conf_file
get_uniq_config_file () {
    exit_if_args_not $# 2 "2193333387"
    dir_input=$(echo $1 | sed 's#/$##g')
    conf_file="$2"
    cd "$dir_input/"
    echo -n "" > "$script_path/.tmp.tmp"
    echo -n "" > "$script_path/.drive_list.tmp"
    find . -maxdepth 1 -type d ! -path . | sed 's#^./##g' | sort > "$script_path/.drive_list.tmp"

    while IFS= read -r drive
    do
        #if config file exists
        if [ -r "$drive/$conf_file" ]
        then
            path=$(pwd)
            echo "$path/$drive/$conf_file" >> "$script_path/.tmp.tmp"
        fi
    done < "$script_path/.drive_list.tmp"
    file_count=$(cat "$script_path/.tmp.tmp" | wc -l | sed 's# ##g')
    if [ "$file_count" == "1" ]
    then
        cat "$script_path/.tmp.tmp"
    else
        echo "false"
    fi
}

# shutdown $error $message "$pi_scripts_source_drive_path"
log_n_shutdown () {
    exit_if_args_not $# 3 "511280623"
    echo "shutting down now $1, $2" >> "$script_path/recent.log"
    cat "$script_path/recent.log" > "$pi_scripts_source_drive_path/logs/pi_scripts_on_boot_recent.log"
    # simple_shutdown
    pop_term_and_ask_to_shutdown
}

# shutdown $error $message "$pi_scripts_source_drive_path"
simple_shutdown () {
    echo "shutdown now if pi"
    echo "shutdown now if pi" >> "$script_path/recent.log"
    if [ "$is_pi" == "true" ]
    then
        read -t 10 -r -p "Cancel shutdown? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            echo "OK, cancelling shutdown"
        else
            echo "shutdown now"
            sudo shutdown -h now
            exit
        fi
    fi
    exit 1
}

pop_term_and_ask_to_shutdown () {
    echo "if pi, then pop up terminal and ask to shutdown"
    if [ "$is_pi" == "true" ]
    then
        xterm -hold -e echo "pi_scripts_on_boot done!"
    fi
}