#!/bin/bash
# Because I'm tired of things not working.

kernelver=$(uname -r | cut -d- -f1)

#-----------------------------------------------------------------------------------------------------------------------------------
# To make UPower not detect the batteries of your Unifying (tm) devices
#-----------------------------------------------------------------------------------------------------------------------------------
function unifying(){
        sudo cp /lib/udev/rules.d/95-upower-csr.rules /etc/udev/rules.d/95-upower-csr.rules
        sudo sed 's/, ENV{UPOWER_BATTERY_TYPE}=\"unifying\"//g' -i /etc/udev/rules.d/95-upower-csr.rules
}

#-----------------------------------------------------------------------------------------------------------------------------------
# To fix unstable wifi when using bluetooth
#-----------------------------------------------------------------------------------------------------------------------------------
function wififix(){
        if [ $(echo "$kernelver >= 3.12" | bc -l) ];
        then
                echo "options ath9k nohwcrypt=1 blink=1 btcoex_enable=1 bt_ant_diversity=1" | sudo tee /etc/modprobe.d/ath9k.conf
        else
                echo "options ath9k nohwcrypt=1 blink=1 btcoex_enable=1 enable_diversity=1" | sudo tee /etc/modprobe.d/ath9k.conf
        fi
}

#-----------------------------------------------------------------------------------------------------------------------------------
# To keep Ubuntu and derivatives from blocking i2c-i801
function unblocktouch(){
        if [[ -f /etc/modprobe.d/blacklist.conf ]];
        then
                sed 's/blacklist i2c_i801/#blacklist i2c_i801/g' -i /etc/modprobe.d/blacklist.conf
        fi
}

#-----------------------------------------------------------------------------------------------------------------------------------
# To fix touchpad modules not loading in the right order. This also makes the touchpad resume correctly from sleep.
function touchorder(){
        echo "softdep chromeos_laptop pre: i2c-core i2c-i801 cyapa" | sudo tee /etc/modprobe.d/chromeos_laptop.conf
}

#-----------------------------------------------------------------------------------------------------------------------------------
# Various power save features for Intel GPUs
function gpusave(){
	read -p "Would you like to have a verbose boot? " yn
	case $yn in
		[Yy]* ) quiet="quiet";;
		[Nn]* ) ;;
		* ) echo "Please answer y or n.";;
	esac
	read -p "Do you want to keep your splash screen on boot? " yn
	case $yn in
		[Yy]* ) splash="splash";;
		[Nn]* ) ;;
		* ) echo "Please answer y or n.";;
	esac
	sudo sed 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="'$quiet' '$splash' i915.lvds_downclock=1 i915.i915_enable_fbc=1 i915.i915_enable_rc6=1 drm.vblankoffdelay=1"/' -i /etc/default/grub
	sudo grub-mkconfig -o /boot/grub/grub.cfg
}

unifying
wififix
unblocktouch
touchorder
gpusave
