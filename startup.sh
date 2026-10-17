#!/bin/bash
# Replace Tomcat's default port 8080 with Render's dynamic $PORT (default to 10000 if not set)
PORT="${PORT:-10000}"
sed -i "s/port=\"8080\"/port=\"$PORT\"/g" /usr/local/tomcat/conf/server.xml

# Disable Tomcat's shutdown port (8005) so Render health probes do not trigger "Invalid shutdown command"
sed -i 's/port="8005"/port="-1"/g' /usr/local/tomcat/conf/server.xml

# Start Tomcat with exec to handle lifecycle signals properly
exec catalina.sh run