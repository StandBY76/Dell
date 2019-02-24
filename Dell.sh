#!/bin/sh
# Auto rotate screen based on device orientation

# Receives input from monitor-sensor (part of iio-sensor-proxy package)
# Screen orientation and launcher location is set based upon accelerometer position
# Launcher will be on the left in a landscape orientation and on the bottom in a portrait orientation
# This script should be added to startup applications for the user

MINLUX=700

ONBOARD_PID=""
Icon="/home/petr/.DellMy/Icoon.png"
Icoff="/home/petr/.DellMy/Icooff.png"
fconfig=".dell"
state=".state"
id_keyboard=$(xinput -list | grep -e "AT Translated Set 2 keyboard" | cut -d= -f2 | cut -d[ -f1)
id_touch_pad=$(xinput -list | grep -e "DLL06FD:01 04F3:300F Touchpad" | cut -d= -f2 | cut -d[ -f1)
id_touch_screen=$(xinput -list | grep -e "ELAN Touchscreen" | cut -d= -f2 | cut -d[ -f1)

if [ ! -f $fconfig ];
    then
        echo "Creating config file"
        echo "normal" > $fconfig
        ORIENTATION="normal"
    else
        read -r ORIENTATION< $fconfig
fi


# Clear sensor.log so it doesn't get too long over time
#> /home/petr/Coding/Dell/sensor.log

# Launch monitor-sensor and store the output in a variable that can be parsed by the rest of the script
#monitor-sensor >> /home/petr/Coding/Dell/sensor.log 2>&1 &

# Parse output or monitor sensor to get the new orientation whenever the log file is updated
# Possibles are: normal, bottom-up, right-up, left-up
monitor-sensor \
  | while read sensor_line; do

    LUX=$(echo "$sensor_line" | grep 'Light' | grep -oE '[0-9.]*')
    if [ "$LUX" != "" ]
    then
            LUX=${LUX%.*}
            LUX=$((LUX + MINLUX))
            if [ $LUX -gt 1000 ]
            then
                LUX=1000
            fi
            
            LUX=$(awk -v LUX=$LUX 'BEGIN { print ((LUX) / 1000) }')

            MONITOR=$(xrandr | grep " connected" | cut -f1 -d " ")
            xrandr --output $MONITOR --brightness $LUX

            echo LUX: $LUX
    fi


    # ORIENTATION=$(tail -n 1 sensor.log | grep 'orientation' | grep -oE '[^ ]+$')
    ORIENTATION=$(echo "$sensor_line" | grep 'Accelerometer orientation' | grep -oEm 1 '[^ ]+$')

    echo ORIENTATION: "$ORIENTATION" \""$sensor_line"\"
    #echo "$ORIENTATION" > $fconfig

    # Set the actions to be taken for each possible orientation
    if [ "$ORIENTATION" = "bottom-up" ] 
    then
            notify-send -i $Icoff "UPSIDEDOWN mode" \ " ";
    #        xinput disable $id_keyboard
    #        xinput disable $id_touch_pad
    ##        xinput enable 15
            xrandr --output eDP-1 --rotate inverted
            xinput set-float-prop $id_touch_screen "Coordinate Transformation Matrix" -1 0 1 0 -1 1 0 0 1

    ##        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 1 1
    ##        xinput set-prop $id_touch_screen "Evdev Axes Swap" 0
            if [ "$ONBOARD_PID" = "" ]; then
                onboard &
                ONBOARD_PID="$!"
            fi

    elif [ "$ORIENTATION" = "normal" ]
    then
            notify-send -i $Icon "NORMAL mode" \ " ";
    ##        xinput enable $id_keyboard
    ##        xinput enable $id_touch_pad
            xrandr --output eDP-1 --rotate normal
            xinput set-float-prop $id_touch_screen "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1

    ##        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 0 0
    ##        xinput set-prop $id_touch_screen "Evdev Axes Swap" 0
            if [ "$ONBOARD_PID" != "" ]; then
                kill -s 9 $ONBOARD_PID
                ONBOARD_PID=""
            fi
            
    elif [ "$1" = "-r" ]
    then
            notify-send -i $Icoff "RIGHTSIDE mode" \ " ";
    #        xinput disable $id_keyboard
    #        xinput disable $id_touch_pad
    #        xrandr --output eDP-1 --rotate right
    #        xinput set-float-prop $id_touch_screen "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1

    ##        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 0 1
    ##        xinput set-prop $id_touch_screen "Evdev Axes Swap" 1
    #        onboard &

    elif [ "$1" = "-l" ]
    then
            notify-send -i $Icoff "LEFTTSIDE mode" \ " ";
    #        xinput disable $id_keyboard
    #        xinput disable $id_touch_pad
    #        xrandr --output eDP-1 --rotate left
    #        xinput set-float-prop $id_touch_screen "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1

    ##        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 0 1
    ##        xinput set-prop $id_touch_screen "Evdev Axes Swap" 1
    #        onboard &
    fi
    
done
