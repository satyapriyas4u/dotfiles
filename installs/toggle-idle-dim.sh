#!/bin/bash

# Ensure it runs in the correct GNOME session
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

# Path to gsettings
GSETTINGS="/usr/bin/gsettings"

# Detect battery device and charging state
BATTERY_DEVICE=$(upower -e | grep 'BAT')
STATE=$(upower -i "$BATTERY_DEVICE" | grep "state" | awk '{print $2}')

# Debug log path
LOG_FILE=~/Documents/Shell/battery_idle_dim.log

# Log battery state
echo "[$(date)] Battery state: $STATE" >> "$LOG_FILE"

# Apply setting based on state
if [ "$STATE" = "discharging" ]; then
    $GSETTINGS set org.gnome.settings-daemon.plugins.power idle-dim true
else
    $GSETTINGS set org.gnome.settings-daemon.plugins.power idle-dim false
fi

# Log current value of idle-dim after setting
CURRENT_VALUE=$($GSETTINGS get org.gnome.settings-daemon.plugins.power idle-dim)
echo "[$(date)] Current idle-dim value: $CURRENT_VALUE" >> "$LOG_FILE"

