#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
#polybar black >>/tmp/polybar1.log 2>&1 & disown
polybar example -r >>/tmp/polybar1.log 2>&1 & disown & 

myMonitor=$(xrandr --query | grep 'HDMI-1-0')

if [[ $myMonitor = HDMI-1-0\ connected* ]]; then
    polybar external -r >>/tmp/polybar2.log 2>&0& disown &
fi

echo "Bars launched..."
