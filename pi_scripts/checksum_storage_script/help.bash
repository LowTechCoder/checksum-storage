#loop
while IFS= read -r drive
do
done < "$script_path/.tmp.tmp"

#if file exists
if [ -f "$drive/$conf_file" ]

# clean_config_file "$file_input" "$file_output" 
clean_config_file "$script_path/.tmp.tmp" "$script_path/.current_configs.tmp" 

#if var not set
if [ ! -z "$name" ]

#conditional with multiple 
if [ ! -s "$1" ] || [ ! -f "$1" ]

#is file readable
#test if file or directory exists, and if it's readable
if [ ! -r "$1" ]

# exit_on_sub_exit "84729478" "function_name"
exit_on_sub_exit () {
    if [ $? != 0 ]
    then
        recent_log "error: $1 $2, exiting"
        exit
    fi
}

#get the drive from the config file path using a search 
# bash get_config_file_path $input_search_text $input_path_list $conf_file
drive_path=$(get_config_file_path "^name=$scan_drive_value$" "$script_path/.drive_list.tmp" "$conf_file") || \
    skip_on_error "4244974667" "bad get_config_file_path"

drive=$(get_drive_from_config_path "$drive_path" "$conf_file")

# get value from a config file, and use the source path config
enable_script=$(get_value_from_config "$source_path_n_config" "^enable_script=.*$")
if [ "$source_name" == "true" ]

path_n_file="$1"
echo "whole: $path_n_file"
#only show file from path and file
file=$(basename $path_n_file)
echo "file: $file"
#only show path from path and file
path=$(dirname $path_n_file)
echo "path: $path"