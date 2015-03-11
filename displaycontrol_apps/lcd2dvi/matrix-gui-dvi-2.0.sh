#! /bin/sh

matrixgui="/usr/bin/matrix_browser"
ROTATION=""
GUI_OPTS="-qws $ROTATION http://localhost:80/"
PIDFILE="/var/run/matrix-gui-2.0.pid"

test -x "$matrixgui" || exit 0

tsfile=/etc/pointercal

case "$1" in
  start)
    chvt 4

    # ARM9 devices get a lot of alignment trap errors with the current
    # version of Qt (4.7.2) that we use.  The printing of these messages
    # is causing a severe slowdown with matrix and other Qt applications
    # that matrix launches.  The root cause is under investigation and an
    # issue is being filed in the Qt JIRA tracker.  For now using the
    # following command will do a software fixup of the alignment trap errors
    # in the kernel.  This should have no impact on cortex-A8 devices.
    echo 2 > /proc/cpu/alignment

    # Do not try to calibrate the touchscreen if it doesn't exist.
    if [ -e /dev/input/touchscreen0 ]
    then
#        export QWS_MOUSE_PROTO=Tslib:/dev/input/touchscreen0
        # Check if the SD card is mounted and the first partition is
        # vfat.  If so let's write the pointercal file there so that if
        # someone messes up calibration they can just delete the file from
        # any system and reboot the board.
        mount | grep /media/mmcblk0p1 | grep vfat > /dev/null 2>&1
        if [ "$?" = "0" ]
        then
            tsfile=/media/mmcblk0p1/pointercal
            export TSLIB_CALIBFILE=$tsfile
        fi

        if [ ! -f $tsfile ] ; then
            echo -n "Calibrating touchscreen (first time only)"
            ts_calibrate
            echo "."
            # If we create a pointercal file and it was not in /etc/pointercal
            # let's copy it there as well if it does not already exist.
            if [ ! -f /etc/pointercal -a -f $tsfile ]
            then
                cp $tsfile /etc/pointercal
            fi
        fi
    fi

    #Clear out the the tmp and lock directory
    cd /usr/share/matrix-gui-2.0
    rm -rf tmp/* 
    rm -rf lock/*
    cd - 

	if [ -e $PIDFILE ]; then
      PIDDIR=/proc/$(cat $PIDFILE)
      if [ -d ${PIDDIR} -a  "$(readlink -f ${PIDDIR}/exe)" = "${matrixgui}" ]; then
        echo "$DESC already started; not starting."
      else
        echo "Removing stale PID file $PIDFILE."
        rm -f $PIDFILE
      fi
    fi

    echo -n "Starting Matrix GUI application"
    start-stop-daemon --start --quiet --background --exec $matrixgui -- $GUI_OPTS
	pidof ${matrixgui} > $PIDFILE
    echo "."
    ;;

  stop)
    echo -n "Stopping Matrix GUI application"
    start-stop-daemon --stop --quiet --pidfile /var/run/matrix-gui-2.0.pid
    echo "."
    ;;
  *)
    echo "Usage: /etc/init.d/matrix-gui-2.0 {start|stop}"
    exit 1
esac

exit 0
