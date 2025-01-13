#!/bin/bash
#https://magpi.raspberrypi.com/articles/pi-zero-w-smart-usb-flash-drive
#https://raspberrypi.stackexchange.com/questions/107010/change-raspberry-pi-zero-usb-gadget-name-from-linux-file-stor-gadget
#https://github.com/paperless-ngx/paperless-ngx/discussions/3946

# disable gadget
cd /sys/kernel/config/usb_gadget/gadget1/
sudo bash -c 'echo > UDC'

# mounting
sudo mount -a
