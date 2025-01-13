#!/bin/bash
#
# https://raspberrypi.stackexchange.com/questions/107010/change-raspberry-pi-zero-usb-gadget-name-from-linux-file-stor-gadget
#
# libcomposite USB mass storage device gadget for raspberry pi zero
# Call this script on Pi Zero startup by adding its full path to /etc/rc.local
# Assumes you have created the backing file for the storage device with something like this:
#  sudo dd if=/dev/zero of=/home/pi/piusb_fat32.bin bs=1 count=0 seek=128M
#  sudo mkdosfs /home/pi/piusb_fat32.bin -n FAT32VOL11

# And done these two steps once:
#  sudo echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt
#  sudo echo "dwc2" | sudo tee -a /etc/modules  

# umounting share to avoid simultaneous acces
sudo umount /mnt/usb_share

# Do some simple logging so we know the script is launching at startup
date | tee -a /home/pi/startup_script.log
echo Starting startup_script | tee -a /home/pi/startup_script.log

#Load the kernel module
modprobe libcomposite

#Gadget name (gadget1 is just an arbitrary name)
mkdir -p /sys/kernel/config/usb_gadget/gadget1
cd /sys/kernel/config/usb_gadget/gadget1

#hardware id
echo 0x0419 > bcdDevice
echo 0x0200 > bcdUSB
echo 0x0781 > idVendor # Sandisk
echo 0x556e > idProduct # Cruzer Edge

#device config
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
echo 0x08 > bMaxPacketSize0

#More stuff
mkdir -p strings/0x409
mkdir -p strings/0x407
cd strings/0x409
echo 'Sandisk' > manufacturer
echo 'Cruzer Edge' > product
echo 'Serial123456789' > serialnumber
cd ../../
cd strings/0x407
echo 'Sandisk' > manufacturer
echo 'Cruzer Edge' > product
echo 'Serial123456789' > serialnumber

cd ../../

mkdir -p functions/mass_storage.usb0

#Mass Storage 0 config settings
cd functions/mass_storage.usb0
echo 0 > stall
echo 1 > lun.0/removable
echo 0 > lun.0/ro
echo /home/pi/piusb_fat32.bin > lun.0/file
#Note, the next line is important. Host OS will tokenize it as: vendor(len 8) + model(len 16) + rev(len 4)
#Example here: vendor = ABCDEFGH  model = 123456789ABCDEFG  rev = WXYZ
echo 'ABCDEFGH123456789ABCDEFGWXYZ' > lun.0/inquiry_string
cd ../../

#OS Descriptor for Windows
cd os_desc
echo 1 > use
echo 0xcd > b_vendor_code
echo MSFT100 > qw_sign
cd ../

#Bus Hardware Config
mkdir -p configs/c.1
cd configs/c.1
echo 0x80 > bmAttributes
echo 100 > MaxPower
mkdir -p strings/0x409
echo "0" > strings/0x409/configuration
mkdir -p strings/0x407
echo "1" > strings/0x407/configuration
cd ../../
ln -s functions/mass_storage.usb0 configs/c.1
ln -s configs/c.1 os_desc

#Activate the gadget
ls /sys/class/udc > UDC
