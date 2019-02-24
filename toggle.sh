#!/bin/bash
Icon="/home/petr/.DellMy/Icoon.png"
Icoff="/home/petr/.DellMy/Icooff.png"
fconfig=".dell" 
state=".state"
id_keyboard=$(xinput -list | grep -e "AT Translated Set 2 keyboard" | cut -d= -f2 | cut -d[ -f1)
id_touch_pad=$(xinput -list | grep -e "DLL06FD:01 04F3:300F Touchpad" | cut -d= -f2 | cut -d[ -f1)
id_touch_screen=$(xinput -list | grep -e "ELAN Touchscreen" | cut -d= -f2 | cut -d[ -f1)


# Secure to not to run two times.
if [ ! -f $state ];
    then
        echo "Creating state file"
        echo "running" > $state
    else
        echo "Other process running! Exit..."
        exit
fi



if [ ! -f $fconfig ];
    then
        echo "Creating config file"
        echo "normal" > $fconfig
        var="normal"
    else
        read -r var< $fconfig
fi



if [ "$1" = "-u" -o \( $# -eq 0 -a "$var" = "normal" \) ] 
then
        notify-send -i $Icoff "UPSIDEDOWN mode" \ "OFF - Keyboard, touchpad";
        xinput disable $id_keyboard
        xinput disable $id_touch_pad
        xinput enable 15
        echo "upsidedown" > $fconfig
        xrandr --output eDP-1 --rotate inverted
        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 1 1
        xinput set-prop $id_touch_screen "Evdev Axes Swap" 0
        onboard &

elif [ "$1" = "-n" -o \( $# -eq 0 -a \( "$var" = "upsidedown" -o "$var" = "right" -o "$var" = "left" \) \) ]
then
        notify-send -i $Icon "NORMAL mode" \ "ON - Keyboard, touchpad";
        xinput enable $id_keyboard
        xinput enable $id_touch_pad
        echo 'normal' > $fconfig
        xrandr --output eDP-1 --rotate normal
        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 0 0
        xinput set-prop $id_touch_screen "Evdev Axes Swap" 0
        
        rm .state
        kill -s 9 `pgrep -l -u petr | grep onboard | cut -f1 -d" "`
        
elif [ "$1" = "-r" ]
then
        notify-send -i $Icoff "RIGHTSIDE mode" \ "OFF - Keyboard, touchpad";
        xinput disable $id_keyboard
        xinput disable $id_touch_pad
        echo 'right' > $fconfig
        xrandr --output eDP-1 --rotate right
        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 0 1
        xinput set-prop $id_touch_screen "Evdev Axes Swap" 1
        onboard &

elif [ "$1" = "-l" ]
then
        notify-send -i $Icoff "LEFTTSIDE mode" \ "OFF - Keyboard, touchpad";
        xinput disable $id_keyboard
        xinput disable $id_touch_pad
        echo 'left' > $fconfig
        xrandr --output eDP-1 --rotate left
        xinput set-prop $id_touch_screen "Evdev Axis Inversion" 0 1
        xinput set-prop $id_touch_screen "Evdev Axes Swap" 1
        onboard &

else
        echo "Use -n for normal, -r for right, -l for left and -u for upsidedown mode."
        
fi


rm .state
