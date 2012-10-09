#!/bin/sh
# Stop tomcat

/etc/init.d/tomcat stop
sleep 10
PROCESS=`pgrep "java"`
if [ ! -z "$PROCESS" ]
 then
   echo "Killing tomcat, PID:$PROCESS"
   kill $PROCESS
fi
