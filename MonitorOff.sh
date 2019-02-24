#!/bin/bash

sleep 0.5

if [ "$1" = "-l" ]; then
loginctl lock-session
fi

xset dpms force off
