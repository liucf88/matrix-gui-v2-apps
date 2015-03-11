#!/bin/sh

amixer_find="/usr/bin/amixer"
if [ ! -f $amixer_find ]; then
        echo "amixer not found"
        echo "Please connect audio output and install ALSA soundcard driver"
else
	machine_type="`cat /etc/hostname`"
	filename="/usr/share/ti/audio/HistoryOfTI.aac"
	if [ ! -f $filename ]; then
		echo "Audio clip not found"
		exit 1
	fi
	echo ""
	echo ""
	if [ "$machine_type" = "am37x-evm" ]; then
		amixer cset name='HeadsetL Mixer AudioL1' on
		amixer cset name='HeadsetR Mixer AudioR1' on
		amixer -c 0 set Headset 1+ unmute
	elif [ "$machine_type" = "am335x-evm" ]; then
		amixer cset name='PCM Playback Volume' 127
	elif [ "$machine_type" = "omap5-evm" ]; then
		amixer cset name='PCM Playback Volume' 127
	elif [ "$machine_type" = "am437x-evm" ]; then

		# EPOS uses a different configuration
		# we are running on that board
		model_name=`cat /proc/device-tree/model | grep -i epos`

		if [ "$?" = '0' ]; then
			amixer cset name='DAC Playback Volume' 127
			amixer cset name='HP Analog Playback Volume' 66
			amixer cset name='HP Driver Playback Switch' on
			amixer cset name='HP Left Switch' on
			amixer cset name='HP Right Switch' on
			amixer cset name='Output Left From Left DAC' on
			amixer cset name='Output Right From Right DAC' on
		else
			amixer cset name='PCM Playback Volume' 127
		fi
	fi
	echo ""
	echo "Length of audio clip: 18 seconds"
	echo ""
	echo "Launch GStreamer pipeline"
	echo ""
	gst-launch-0.10 filesrc location=$filename ! faad ! alsasink
fi
