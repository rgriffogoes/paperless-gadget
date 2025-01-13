#!/bin/bash
# https://github.com/paperless-ngx/paperless-ngx/discussions/3946
#
SCRIPT_DIR="/home/pi/paperless-gadget"

BASE_DIR="/mnt/usb_share/Brother"
DOC_FILES="$BASE_DIR/*.pdf"
SUCCESS_DIR="$BASE_DIR/success"
FAILURE_DIR="$BASE_DIR/failure"

mkdir -p "$BASE_DIR" "$SUCCESS_DIR" "$FAILURE_DIR"

for f in $DOC_FILES
do
   echo "Processing $f file"
   $SCRIPT_DIR/post2paperless.sh "$f" && mv "$f" $SUCCESS_DIR \
		|| { echo Upload failed, retaining file $f >&2; mv "$f" $FAILURE_DIR; }
done
