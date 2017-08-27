#!/usr/bin/env bash
#
# /etc/rc.d/init.d/alluxio-masterd
#
# chkconfig: 2345 99 15
# description: Alluxio Server & Master Service

. /etc/rc.d/init.d/functions
. /etc/profile # make sure we are using the intended python
PROJECT_HOME=/opt/alluxio
SUPERVISORD=`which supervisord`

function fail {
    logger -p error -t alluxio-masterd -i -- $1
    echo "error: $2"
    exit 1
}

function do_start {
    $SUPERVISORD -c ${PROJECT_HOME}/deploy/ambari/recipe/master-supervisord.conf && echo "Started Alluxio master supervisord"
    echo "Hue started"
}

function do_stop {
    pkill -f "$PROJECT_HOME/deploy/ambari/recipe/master-supervisord.conf" && echo "Stopped Alluxio master supervisord, waiting for Python server to exit..."
    MASTER_PID=`pgrep -f "alluxio.master.AlluxioMaster" 2>/dev/null`
    until [ -z "$MASTER_PID" ]; do
        echo "MASTER_PID=$MASTER_PID, Waiting..."
        sleep 2
        MASTER_PID=`pgrep -f "alluxio.master.AlluxioMaster" 2>/dev/null`
    done
    echo "Alluxio master was successfully stopped."
}

function do_restart {
    do_stop
    do_start
}

function get_status {
    MASTER_PID=`pgrep -f alluxio.master.AlluxioMaster 2>/dev/null`
    if [ -z "$MASTER_PID" ]; then
       echo "stopped"
       return 3
    else
       echo "running"
       return 0
    fi
}

case "$1" in
    start)
        do_start
    ;;
    stop)
        do_stop
    ;;
    restart)
        do_restart
    ;;
    status)
        get_status
    ;;
esac
