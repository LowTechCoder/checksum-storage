New line error:
The last line must be a new line, in this good_config.conf file, or sed will freak out. 

set the systemd service with this file
sudo cp /home/pi/pi_scripts/pi_scripts_on_boot/pi_scripts_on_boot.service /etc/systemd/system/pi_scripts_on_boot.service 
sudo systemctl start pi_scripts_on_boot.service
sudo systemctl stop pi_scripts_on_boot.service
sudo systemctl enable pi_scripts_on_boot.service

Be sure to run the checksum_storage script from within the pi_scripts_on_boot directory using _main.bash


#alternative autostart 
cp /home/pi/pi_scripts/pi_scripts_on_boot/desktop_autostart.conf /home/pi/.config/autostart/.desktop
