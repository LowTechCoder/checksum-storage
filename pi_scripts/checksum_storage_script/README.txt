New line error:
The last line must be a new line, in this good_config.conf file, or sed will freak out. 

ext4 was copying slow, for unkown reasons, so i used exfat for both drives

The excludes.conf can't contain any spaces.  I need to fix this later, so i can add "System Volume Information".  I did 
a workaround by adding the wildcard for spaces

I removed the --delete feature from rsync, so this doesn't actually do a mirror copy from backup1 to backup2 yet.

When copying from any drive to another, rsync has --prune-empty-dirs set so it will skip empty directories.

Be sure to run the checksum_storage script from within the pi_scripts_on_boot directory using _main.bash
