#!/usr/bin/bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix

if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
	echo "Usage:
	$0 <dir containg images>"
	exit 1
fi

# Edit bellow to control the images transition
#export SWWW_TRANSITION_FPS=60
#export SWWW_TRANSITION_STEP=2

# This controls (in seconds) when to switch to the next image
INTERVAL=300

while true; do
	find "$1" \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
			sleep $INTERVAL

      swww img "$img" --transition-fps 60 \
                      --transition-step 250 \
                      --transition-bezier .25,1,1.12,.4 \
                      --transition-type grow \
                      --transition-pos "$(hyprctl cursorpos)" \
                      --transition-duration 2
		done
done
                      #--transition-bezier .43,1.19,1,.4 \
                      #--transition-bezier .42,0,.58,1 \
                      #--transition-angle \  ## wipe和wave用于控制擦除的角度
                      #--transition-type grow \
