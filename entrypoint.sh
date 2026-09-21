#!/bin/bash
sed -i "s/port=\"8080\"/port=\"${PORT:-8080}\"/g" /usr/local/tomcat/conf/server.xml
catalina.sh run
