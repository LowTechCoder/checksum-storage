#!/bin/bash
#bash create_checksums.bash "$dir_input" "$file_input" $create_checksums_name

source include.bash
exit_if_args_not $# 3 "28374483837"

verbose_log ""
verbose_log "  --  create checksums  --  "

#args
dir_input=$(echo $1 | sed 's#/$##g')
file_input=$2
create_checksums_name=$3

#empty files
#exit checks
exit_if_dir_missing "$dir_input" "353747658"
exit_if_file_empty_or_missing "$file_input" "3543545757658"

verbose_log "for: name=$create_checksums_name"
verbose_log "in directory:"
verbose_log "$dir_input/"

cd "$dir_input"

# looping through: "$script_path/.rec_dir_list.tmp"
while IFS= read -r line
do
    cd "$line"
    path=$(pwd)
    #if dir is empty
    eval_this=$(echo "find . -type f -maxdepth 1 ! -path . ! -name '.file_list.tmp' ! -iname '$checksum_dir' $exclude_find")
    find_empty=$(eval $eval_this)

    if [ ! -z "$find_empty" ]
    then
        if [ ! -d "$checksum_dir" ]
        then
            mkdir "$checksum_dir"
        fi
        eval $eval_this | sed 's#^./##g' > "$checksum_dir/.file_list.tmp"

        #loop through "$checksum_dir/.file_list.tmp"
        while IFS= read -r line2
        do
            #if there is an existing checksum
            if [ -r "$checksum_dir/$line2.checksum" ]
            then
                checksum_file=$(shasum -a 1 "$line2") || \
                    create_checksum_exit "couldn't create checksum for scan, exiting" "2189344606" "$line2"
                existing_checksum=$(cat "$checksum_dir/$line2.checksum") || \
                    create_checksum_exit "couldn't read existing checksum, exiting" "2028451042" "$line2"
                if [ "$checksum_file" == "$existing_checksum" ]
                then
                    #if the existing checksum is the same as the new checksum
                    verbose_log "checksum hasn't changed, skip creating a new one."
                    verbose_log "$path/$line2"
                else
                    #if the new checksum isn't the same, then overwrite it
                    echo "$checksum_file" > "$checksum_dir/$line2.checksum" || create_checksum_exit "couldn't create checksum" "756365375979" "$line2"
                    verbose_log "create_checksum: $path/$line2"
                fi
            else
                #if there is no existing checksum then create a new one
                checksum_file=$(shasum -a 1 "$line2") || \
                    create_checksum_exit "couldn't create checksum for scan, exiting" "2189344606" "$line2"
                echo "$checksum_file" > "$checksum_dir/$line2.checksum" || create_checksum_exit "couldn't create checksum" "756365375979" "$line2"
                verbose_log "create_checksum: $path/$line2"
            fi
        done < "$checksum_dir/.file_list.tmp"

    fi

    cd "$dir_input"
done < "$file_input"
verbose_log ""
verbose_log "  --  create checksums complete  --  "