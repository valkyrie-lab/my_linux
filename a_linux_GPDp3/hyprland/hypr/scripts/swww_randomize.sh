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
                      --transition-bezier 1,0.95,.94,-0.5 \
                      --transition-type grow \
                      --transition-pos "$(hyprctl cursorpos)" \
                      --transition-duration 4
		done
done

## 立方贝塞尔
#(1,1,0,0) # 缓进快出
#(.97,.26,.0,.1)
#(.78,.78,0.5,0.1) # 平缓过度
#(1,0.95,.94,-0.5) # 弹弓效果
#(0,1.16,1,-0.29)

# 快-> 慢 暂留
#(https://cubic-bezier.com/#.14,.9,.79,.11)

                      #--transition-bezier .01,.85,1.3,.1 \ duration 1
                      #--transition-bezier .1,.85,1.3,.1 \1
                      #--transition-bezier .1,1,.1,.1 \1
                      #--transition-bezier .43,1.19,1,.4 \
                      #--transition-angle \  ## wipe和wave用于控制擦除的角度
                      #--transition-type grow \
