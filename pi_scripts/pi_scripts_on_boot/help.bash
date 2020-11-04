#loop
while IFS= read -r drive
do
done < "$script_path/.tmp.tmp"

#if file exists
if [ -f "$drive/$conf_file" ]

# clean_config_file "$file_input" "$file_output" 
clean_config_file "$script_path/.tmp.tmp" "$script_path/.current_configs.tmp" 

search_line=$(cat "$script_path/.tmp.tmp" | grep "$input_search_text")
#if this config has the search pattern, then return the full path of this config
# ! -z is for var not empty or not set
if [ ! -z "$search_line" ]
then
    final_search=$(echo "$drive_path/$conf_file")
fi

# is for var not empty or not set
if [ ! -z "$name" ]

# get_line_from_uniq_file_list "$file_input" "$line_search"
get_line_from_uniq_file_list "$file_input" "$line_search"

#conditional with multiple 
if [ ! -s "$1" ] || [ ! -f "$1" ]

# test if file or directory exists, and if it's readable
if [ ! -r "$1" ]

# if exit code is set to 1 or above
if [ $? != 0 ]

##################### begin
source_path_n_config=$(get_config_file_path "^name=source$" "$script_path/.drive_list.tmp" "$conf_file") || \
    skip_on_error "4244974667" "bad get_config_file_path"
echo "source_path_n_config: $source_path_n_config"

valtest=$(get_value_from_config "$source_path_n_config" "^name=.*$")
echo "valtest: $valtest"
##################### end
