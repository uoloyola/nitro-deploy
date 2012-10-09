#!/bin/sh
# Stop tomcat

/etc/init.d/tomcat stop
sleep 10
PROCESS=`pgrep -f "tomcat"`
if [ ! -z "$PROCESS" ]
 then
   echo "Killing tomcat, PID:$PROCESS"
   kill -9 $PROCESS
fi

