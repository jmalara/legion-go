#!/bin/bash
# Legion Go 2 brightness control via sysfs
#
# Bypasses the broken Steam slider on stock SteamOS.
# Usage:
#   legion-bright.sh           # show current
#   legion-bright.sh get       # show current as percent
#   legion-bright.sh 50        # set to 50%
#   legion-bright.sh +10       # increase by 10%
#   legion-bright.sh -10       # decrease by 10%
#
# No root needed — /sys/class/backlight/amdgpu_bl0/brightness is owned by deck.

set -e

BL=/sys/class/backlight/amdgpu_bl0/brightness
MAX=$(cat /sys/class/backlight/amdgpu_bl0/max_brightness)
CUR=$(cat $BL)
CUR_PCT=$(( CUR * 100 / MAX ))

case "$1" in
    ""|get)
        echo "$CUR_PCT%"
        ;;
    +*|-*)
        delta=${1//[!0-9-]/}
        sign=${1:0:1}
        new=$(( CUR_PCT $sign $delta ))
        [ $new -gt 100 ] && new=100
        [ $new -lt 1 ] && new=1
        echo $(( MAX * new / 100 )) > $BL
        echo "Brightness: $new%"
        ;;
    [0-9]*)
        pct=$1
        [ $pct -gt 100 ] && pct=100
        [ $pct -lt 1 ] && pct=1
        echo $(( MAX * pct / 100 )) > $BL
        echo "Brightness: $pct%"
        ;;
    *)
        echo "Usage: $0 [+N | -N | N | get]"
        echo "Current: $CUR_PCT%"
        exit 1
        ;;
esac
