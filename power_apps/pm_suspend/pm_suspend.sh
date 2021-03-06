# Module: pm_suspend
#
# Description: This script is used to put the board into a suspended state
# 
# Copyright (C) 2010 Texas Instruments Incorporated - http://www.ti.com/
#
#  Redistribution and use in source and binary forms, with or withou
#  modification, are permitted provided that the following conditions
#  are met:
#
#  Redistributions of source code must retain the above copyright
#  notice, this list of conditions and the following disclaimer.
#  
#  Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the
#  distribution.
#
#  Neither the name of Texas Instruments Incorporated nor the names of
#  its contributors may be used to endorse or promote products derived
#  from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

cat /proc/cpuinfo  | grep am335xevm > /dev/null

if [ `echo $?` = 0 ]
then
    cat /proc/driver/musb_hdrc.0 | grep "OTG state" | grep inactive > /dev/null

    if [ `echo $?` = 1 ]
    then
        echo "Board is unable to suspend since the USB port is set to device mode."
        echo "To allow suspend to work you have the following choices:"
        echo "  Unplug the cable connected to the USB OTG port on the am335x from"
        echo "  the USB host (machine connected to the am335x via USB)"
        echo "  Rmmod "g_mass_storage" driver"
        exit
    fi
fi

if [ ! -d /debug ]
then
    mkdir /debug
fi

mountpoint /debug > /dev/null 2>&1
if [ $? -ne 0 ];
then
  mount -t debugfs debugfs /debug
fi

if [ -e /debug/pm_debug/sleep_while_idle ]
then
    echo 1 > /debug/pm_debug/sleep_while_idle
fi

if [ -e /debug/pm_debug/enable_off_mode ]
then
    echo 1 > /debug/pm_debug/enable_off_mode
fi

echo mem > /sys/power/state
echo " "
echo "Platform has resumed normal operation.  Press Close to continue..."
echo " "

