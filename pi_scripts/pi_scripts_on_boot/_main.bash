#!/bin/bash
#bash _main.bash
#scripts should follow this format:
#bash command $input $output $arg1 $arg2

#fixme go through when done, and delete old commented stuff.
echo ""
source include.bash

conf_file="pi_scripts_on_boot.conf"
skip_pi_scripts_on_boot="false"
date > "$script_path/recent.log"

# if pi, then sleep till drives are mounted.  Turn this up if needed.
if [[ "$is_pi" == "true" ]]
then
    echo "waiting for pi to boot.  waiting 40 seconds"
    sleep 40
    echo "starting script"
fi

###################################################
          # -- BEGIN PI BOOT SCRIPT -- #
###################################################

pi_scripts_on_boot_config=$(get_uniq_config_file "$mounts_dir" "$conf_file")

if [ "$pi_scripts_on_boot_config" == "false" ]
then
    echo "no pi_scripts_on_boot_config was found, exiting script" >> "$script_path/recent.log"
    exit 1
else
    pi_scripts_source_drive_path=$(echo "$pi_scripts_on_boot_config" | sed "s#$conf_file##g"| sed 's#/$##g')
fi

bash validate_config_file.bash "$pi_scripts_on_boot_config" "$script_path/good_config.conf" || \
    log_n_shutdown "2124021847" "couldn't validate configs, shutting down" "$pi_scripts_source_drive_path"

pi_scripts_on_boot_enabled=$(get_value_from_config "$pi_scripts_on_boot_config" "^enable_script=.*$")
if [ "$pi_scripts_on_boot_enabled" == "true" ]
then
    echo -n "" > "$pi_scripts_source_drive_path/logs/checksum_storage_recent.log"
    echo -n "" > "$pi_scripts_source_drive_path/logs/checksum_storage_unexpected.log"
    echo -n "" > "$pi_scripts_source_drive_path/logs/checksum_storage_verbose.log"
    echo -n "" > "$pi_scripts_source_drive_path/logs/pi_scripts_on_boot_recent.log"
    echo "pi_script_on_boot is enabled, continuing pi script"
    echo "pi_script_on_boot is enabled, continuing pi script" >> "$script_path/recent.log"
else
    echo "pi_script_on_boot is disabled in config, exiting"
    echo "pi_script_on_boot is disabled in config, exiting" >> "$script_path/recent.log"
    cat "$script_path/recent.log" >> "$pi_scripts_source_drive_path/logs/pi_scripts_on_boot_recent.log"
    exit 1
fi

###################################################
     # -- BEGIN CHECKSUM STORAGE SCRIPT -- #
###################################################

skip_checksum_storage_script="false"
conf_file="checksum_storage.conf"

date > "../checksum_storage_script/recent.log"
date > "../checksum_storage_script/verbose.log"

# bash get_drive_list_with_config.bash "$dir_input" "$file_output"
bash get_drive_list_that_has_config.bash "$mounts_dir" "$script_path/.drive_list.tmp" "$conf_file" || \
    skip_checksum_storage_script_func "4243425260" "couldn't get drive list"

source_path_n_config=$(get_config_file_path "^name=source$" "$script_path/.drive_list.tmp" "$conf_file") || \
    skip_checksum_storage_script_func "4244974667" "bad get_config_file_path"
if [ "$source_path_n_config" == "false" ]
then
    skip_checksum_storage_script="true"
    echo "No source was found for the checksum_storage script." >> "$script_path/recent.log"
    echo "Skipping checksum_storage script." >> "$script_path/recent.log"
else
    source_path=$(echo "$source_path_n_config" | sed "s#$conf_file##g" | sed 's#/$##g')
fi

#getting backup1 and backup2 for other pi scripts not related to checksum_storage script.
if [ "$pi_scripts_on_boot_enabled" == "true" ]
then
    backup1_path_n_config=$(get_config_file_path "^name=backup1$" "$script_path/.drive_list.tmp" "$conf_file") || \
        finish_log_n_exit "2271636808" "bad get_config_file_path" "$source_path"
    if [ "$backup1_path_n_config" != "false" ]
    then
        backup1_path=$(echo "$backup1_path_n_config" | sed "s#$conf_file##g" | sed 's#/$##g')
    fi

    backup2_path_n_config=$(get_config_file_path "^name=backup2$" "$script_path/.drive_list.tmp" "$conf_file") || \
        finish_log_n_exit "2271636808" "bad get_config_file_path" "$source_path"
    if [ "$backup2_path_n_config" != "false" ]
    then
        backup2_path=$(echo "$backup2_path_n_config" | sed "s#$conf_file##g" | sed 's#/$##g')
    fi
fi

if [[ "$skip_checksum_storage_script" == "false" ]]
then
    cd ../checksum_storage_script/
    date > "$script_path/unexpected.log"
    bash ../checksum_storage_script/_main.bash "$mounts_dir" "$source_path_n_config" >> "$script_path/unexpected.log" 2>&1
    mkdir -p "$source_path/logs/"
    cat "$script_path/unexpected.log" > "$source_path/logs/checksum_storage_unexpected.log"
fi

#custom script from souce drive
if [ "$pi_scripts_on_boot_enabled" == "true" ]
then
    cd "$script_path"
    source "$source_path/run_custom_script_from_source_drive.bash"
fi

###################################################
        # -- CONTINUE PI BOOT SCRIPT -- #
###################################################

if [ -d "$source_path" ] || [ -r "$source_path" ]
then
    echo "pi_scripts_on_boot done, shutdown here or spin down drives" >> "$script_path/recent.log"
    cat "$script_path/recent.log" > "$pi_scripts_source_drive_path/logs/pi_scripts_on_boot_recent.log"
fi

simple_shutdown