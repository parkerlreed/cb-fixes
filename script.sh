#!/bin/bash
# Because I'm tired of things not working.

kernelver=$(uname -r | cut -d- -f1)

#-----------------------------------------------------------------------------------------------------------------------------------
# To make UPower not detect the batteries of your Unifying (tm) devices
#-----------------------------------------------------------------------------------------------------------------------------------
sudo cp /lib/udev/rules.d/95-upower-csr.rules /etc/udev/rules.d/95-upower-csr.rules
sudo sed 's/, ENV{UPOWER_BATTERY_TYPE}=\"unifying\"//g' -i /etc/udev/rules.d/95-upower-csr.rules

#-----------------------------------------------------------------------------------------------------------------------------------
# To fix unstable wifi when using bluetooth
#-----------------------------------------------------------------------------------------------------------------------------------
if [ $(echo "$kernelver >= 3.12" | bc -l) ];
then
        echo "options ath9k nohwcrypt=1 blink=1 btcoex_enable=1 bt_ant_diversity=1 | sudo tee /etc/modprobe.d/ath9k.conf
else
        echo "options ath9k nohwcrypt=1 blink=1 btcoex_enable=1 enable_diversity=1 | sudo tee /etc/modprobe.d/ath9k.conf
fi


#-----------------------------------------------------------------------------------------------------------------------------------
# To keep Ubuntu and derivatives from blocking i2c-i801
if [[ -f /etc/modprobe.d/blacklist.conf ]];
then
        sed 's/blacklist i2c_i801/#blacklist i2c_i801/g' -i /etc/modprobe.d/blacklist.conf
fi


#-----------------------------------------------------------------------------------------------------------------------------------
# To fix touchpad modules not loading in the right order
echo "softdep chromeos_laptop pre: i2c-core i2c-i801 cyapa" | sudo tee /etc/modprobe.d/chromeos_laptop.conf

