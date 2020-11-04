# checksum-storage

LowTech Checksum Storage

This bash script is a storage solution for a raspberry pi.  Heres what it can do:

* Create checksums for the files on the source drive.
* Copy files and checksums from a source drive to a destination drive.
* Copy files and checksums from the destination drive, to a secondary destination drive.
* Scan source or destination drives for file corruption using the checksums.
* Use any filesystem.
* It can do all of the above without needing a keyboard, mouse or monitor or network.  Most of the configuration goes in the source drive.

When you power on the Raspberry Pi, the Checksum Storage script will read the config files on the source drive, and run the script, then shut it's self off.  It's perfect for making overnight backups.  Then you can view the log files on the source drive to see if everything went ok.

This script could be dangerous to your data.  I'm still testing it for stability.  Use at your own risk!

More details on how to install are coming.