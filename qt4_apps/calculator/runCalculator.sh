#!/bin/sh

pidof matrix_browser > /dev/null 2>&1
if [ $? == 0 ]
then
        /usr/bin/qtopia/examples/widgets/calculator/calculator
else
        /usr/bin/qtopia/examples/widgets/calculator/calculator -qws
fi
