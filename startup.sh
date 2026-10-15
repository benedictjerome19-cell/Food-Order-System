#!/bin/bash
# Replace Tomcat's default port 8080 with Render's dynamic $PORT (default to 10000 if not set)
PORT="${PORT:-10000}"
sed -i "s/port=\"8080\"/port=\"$PORT\"/g" /usr/local/tomcat/conf/server.xml

# Start Tomcat
catalina.sh run