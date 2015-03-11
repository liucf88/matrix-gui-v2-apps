#!/bin/sh

pidof matrix_browser > /dev/null 2>&1
if [ $? == 0 ]
then
	/usr/bin/qtopia/demos/deform/deform -small-screen
else
	/usr/bin/qtopia/demos/deform/deform -small-screen -qws
fi
