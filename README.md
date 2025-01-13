The original idea was to use a Raspberry Pi Zero in gadget mode to enable a non-wifi `Brother` scanner to send scans to a [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) server.

Unfortunatelly, the PiZ gadget mode was never stable enough (e.g.: usb mass storage not detected by host device, files not updated, etc), and this setup was abandonned.

Other had success, so please see full [discussion](https://github.com/paperless-ngx/paperless-ngx/discussions/3946) in the main repo. 

I eventually got a dedicated Brother scanner and I'm using the scripts provided in the discussions: uses Brother's Linux drivers to detect button press and trigger custom scripts - works nicely, but can't be done on a raspberry pi (no official Brother driver).

**Incomplete instructions below**
-----

Install jq , pass comands 

    sudo apt install jq pass

Setup password store for the user using the script (https://unix.stackexchange.com/questions/53912/i-try-to-add-passwords-to-the-pass-password-manager-but-my-attempts-fail-with). Ensure password store is create with user that runs script

    pass init email@domain.com
    pass insert $hostname

Create a disk file to use with gadget:

https://raspberrypi.stackexchange.com/questions/107010/change-raspberry-pi-zero-usb-gadget-name-from-linux-file-stor-gadget

    sudo dd if=/dev/zero of=/home/pi/piusb_fat32.bin bs=1 count=0 seek=128M
    sudo mkdosfs /home/pi/piusb_fat32.bin -n FAT32VOL11


Install systemd service for mounting usb on start

    sudo cp startgadget.service /etc/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl enable startgadget.service

In order to be able to mount the file in the RPi, create target mounting directory and configure fstab:

    sudo mkdir /mnt/usb_share
    sudo nano /etc/fstab

And add line

    /home/pi/piusb_fat32.bin /mnt/usb_share vfat users,umask=000 0 2

