#!/bin/bash
#bash _main.bash
#scripts should follow this format:
#bash command $input $output $arg1 $arg2

script_path="$( cd "$(dirname "$0")" ; pwd -P )"

# empty file
echo -n "" > "$script_path/recent.log"
date > "$script_path/recent.log"

# exit if there aren't 2 args for this file
if [ "$#" != 2 ] 
then 
    echo "ERROR 422448551, missing script argument, exiting"
    exit 1
fi

mounts_dir=$(echo $1 | sed 's#/$##g')
source_path_n_config=$(echo $2 | sed 's#/$##g')

source include.bash

source_path=$(echo "$source_path_n_config" | sed "s#$conf_file##g" | sed 's#/$##g')

SECONDS=0
secs1=$SECONDS
secs2=0
secs3=0


#clear the logs
date > "$script_path/verbose.log"
date > "$script_path/recent.log"
if [ -r "$source_path" ] && [ "$source_path" != "false" ]
then
    mkdir -p "$source_path/logs/"
    echo -n "" > "$source_path/logs/checksum_storage_verbose.log"
    echo -n "" > "$source_path/logs/unexpected.log"
    echo -n "" > "$source_path/logs/checksum_storage_recent.log"
fi
# if enable_script on source config is false then exit
enable_script=$(get_value_from_config "$source_path_n_config" "^enable_script=.*$")
if [ "$enable_script" == "false" ]
then
    finish_log_n_exit "1650440900" "checksum_storage script from source config is disabled, exiting after final log" "$source_path"
fi


# bash get_drive_list_with_config.bash "$dir_input" "$file_output"
bash get_drive_list_that_has_config.bash "$mounts_dir" "$script_path/.drive_list.tmp" "$conf_file" || \
    finish_log_n_exit "2288935133" "couldn't get drive list" "$source_path"
# any configs that are there, make sure the lines are legit.
bash validate_config_files.bash "$mounts_dir" "$script_path/.drive_list.tmp" "$script_path/good_config.conf" "$conf_file" || \
    finish_log_n_exit "3396971105" "couldn't validate configs" "$source_path"

source_drive_name=$(get_value_from_config "$source_path_n_config" "^name=.*$")
scan_drive_name=$(get_value_from_config "$source_path_n_config" "^scan=.*$")
create_checksums_name=$(get_value_from_config "$source_path_n_config" "^create_checksums_on=.*$")

backup1_path_n_config=$(get_config_file_path "^name=backup1$" "$script_path/.drive_list.tmp" "$conf_file") || \
    finish_log_n_exit "2271636808" "bad get_config_file_path" "$source_path"
if [ "$backup1_path_n_config" != "false" ]
then
    backup1_path=$(echo "$backup1_path_n_config" | sed "s#$conf_file##g" | sed 's#/$##g')
    backup1_drive=$(echo "$backup1_path" | awk -F "/" '{print $NF}')
    backup1_drive_name=$(get_value_from_config "$backup1_path_n_config" "^name=.*$")
fi
backup2_path_n_config=$(get_config_file_path "^name=backup2$" "$script_path/.drive_list.tmp" "$conf_file") || \
    finish_log_n_exit "2271636808" "bad get_config_file_path" "$source_path"
if [ "$backup2_path_n_config" != "false" ]
then
    backup2_path=$(echo "$backup2_path_n_config" | sed "s#$conf_file##g" | sed 's#/$##g')
    backup2_drive=$(echo "$backup2_path" | awk -F "/" '{print $NF}')
    backup2_drive_name=$(get_value_from_config "$backup2_path_n_config" "^name=.*$")
fi


empty_this_file "$script_path/verbose.log"
date > "$script_path/verbose.log"
# make sure the mounts_dir is correct, and not set to mounts_dir/drive/
if [ -d "$mounts_dir/checksum_storage" ]
then
    recent_log "ERROR 3896619924, checksum_storage dir is directly in the $mounts_dir,"
    recent_log "you have defined your mounts_dir in the wrong directory, exiting"
    exit 1
fi
recent_log "running checksum_storage main script"


bash get_drive_list_that_has_config.bash "$mounts_dir" "$script_path/.drive_list.tmp" "$conf_file" || \
    finish_log_n_exit "4086477181" "couldn't get drive list" "$source_path"

# create checksums
if [ "$create_checksums_name" != "false" ]
then

    drive_path=$(get_config_file_path "^name=$create_checksums_name$" "$script_path/.drive_list.tmp" "$conf_file") || \
        finish_log_n_exit "4244974667" "bad get_config_file_path" "$source_path"

    drive=$(get_drive_from_config_path "$drive_path" "$conf_file")
    bash list_dirs.bash "$mounts_dir/$drive/$parent_dir" || \
        finish_log_n_exit "2873358122" "couldn't list directories" "$source_path"
    bash create_checksums.bash "$mounts_dir/$drive/$parent_dir" "$script_path/.rec_dir_list.tmp" "$create_checksums_name" || \
        finish_log_n_exit "1441654138" "couldn't create checksums" "$source_path"
    recent_log ""

    elapsed=$(elapsed_time)
    recent_log "create checksums complete $elapsed"
    recent_log "name=$create_checksums_name"
    recent_log "$mounts_dir/$drive"
    if [ "$create_checksums_name" != "source" ]
    then
        recent_log "POSSIBLE ERROR: created checksums, but not for name=source! YOU PROBABLY SHOULDN'T DO THIS, continuing script"
    fi
else
    recent_log ""
    recent_log "POSSIBLE ERROR: create checksums skipped! YOU PROBABLY SHOULDN'T DO THIS, continuing script"
fi


# -- copy source to backup1 --
copy_source_to_backup1=$(get_value_from_config "$source_path_n_config" "^copy_source_to_backup1=.*$")
if [ "$copy_source_to_backup1" == "true" ]
then
    verbose_log ""
    verbose_log "  --  start rsync copy  --"
    verbose_log "from: name=source"
    verbose_log "$source_path/$parent_dir/"
    verbose_log "to: name=backup1"
    verbose_log "$backup1_path/$parent_dir/"

    rvar=""
    if [ "$verbose" == "true" ]
    then
        rvar="v"
    fi

    rsync -a$rvar --no-perms --no-owner --prune-empty-dirs  --exclude-from="$script_path/excludes.conf" --exclude '.file_list.tmp' "$source_path/$parent_dir/" "$backup1_path/$parent_dir" >> "$script_path/verbose.log"
    if [ $? != 0 ]
    then
        recent_log "ERROR 456798726: rsync ERROR.  Check the verbose.log for last attempted command."
        exit 1
    fi
    recent_log ""
    elapsed=$(elapsed_time)
    recent_log "copy source to backup1 complete  $elapsed"
    recent_log "name=$source_drive_name"
    recent_log "$source_path/$parent_dir/"
    recent_log "to"
    recent_log "name=$backup1_drive_name"
    recent_log "$backup1_path/$parent_dir/"
else
    recent_log ""
    recent_log "copy_source_to_backup1 skipped"
fi

# -- copy backup1 to backup2 --
# get value from a config file, and use the source path config
copy_backup1_to_backup2=$(get_value_from_config "$source_path_n_config" "^copy_backup1_to_backup2=.*$")
if [ "$copy_backup1_to_backup2" == "true" ]
then
    verbose_log ""
    verbose_log "  --  start rsync copy  --"
    verbose_log "from: name=backup1"
    verbose_log "$backup1_path/$parent_dir/"
    verbose_log "to: name=backup2"
    verbose_log "$backup2_path/$parent_dir/"

    rvar=""
    if [ "$verbose" == "true" ]
    then
        rvar="v"
    fi
    rsync -a$rvar --no-perms --no-owner --prune-empty-dirs  --exclude-from="$script_path/excludes.conf" --exclude '.file_list.tmp' "$backup1_path/$parent_dir/" "$backup2_path/$parent_dir" >> "$script_path/verbose.log"
    if [ $? != 0 ]
    then
        recent_log "ERROR 45603622: copy rsync ERROR.  Check the verbose.log for last attempted command."
        exit 1
    fi
    recent_log ""
    elapsed=$(elapsed_time)
    recent_log "copy backup1 to backup2 complete $elapsed"
    recent_log "name=$backup1_drive_name"
    recent_log "$backup1_path/$parent_dir/"
    recent_log "to"
    recent_log "name=$backup2_drive_name"
    recent_log "$backup2_path/$parent_dir/"
else
    recent_log ""
    recent_log "copy_backup1_to_backup2 skipped"
fi

# -- do a checksum scan on specified drive --
scan_drive_name=$(get_value_from_config "$source_path_n_config" "^scan=.*$")
if [ "$scan_drive_name" != "false" ]
then
    recent_log ""
    verbose_log "  --  start checksum scan  --"

    drive_path=$(get_config_file_path "^name=$scan_drive_name$" "$script_path/.drive_list.tmp" "$conf_file") || \
        finish_log_n_exit "4244974667" "bad get_config_file_path" "$source_path"
    drive=$(get_drive_from_config_path "$drive_path" "$conf_file")
    bash checksums_file_scan.bash "$mounts_dir/$drive/$parent_dir" "$scan_drive_name" || \
        finish_log_n_exit "2073170015" "couldn't do checksum file scan" "$source_path"
    
    recent_log ""
    elapsed=$(elapsed_time)
    recent_log "checksum scan complete $elapsed"
    recent_log "name=$scan_drive_name"
    recent_log "$mounts_dir/$drive/$parent_dir"
else
    recent_log ""
    recent_log "scan skipped"
fi

finish_log "$source_path"

