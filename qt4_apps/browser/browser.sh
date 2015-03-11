#!/bin/sh

if test -e /dev/fb0; then
width=`fbset | grep 'geometry' | awk '{print $2}'`
height=`fbset | grep 'geometry' | awk '{print $3}'`

let height=height-38
geo=`echo $width\x$height+0+0`
fi

pidof matrix_browser > /dev/null 2>&1
if [ $? == 0 ]
then
        /usr/bin/qtopia/demos/browser/browser -geometry $geo $*
else
        /usr/bin/qtopia/demos/browser/browser -qws -geometry $geo $*
fi
