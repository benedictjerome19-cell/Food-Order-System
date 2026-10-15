FROM tomcat:9.0-jdk17

# Remove default root webapps to avoid conflicts
RUN rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/examples /usr/local/tomcat/webapps/docs

# Copy your built WAR file as ROOT.war
COPY target/benedictjeromemart.war /usr/local/tomcat/webapps/ROOT.war

# Copy startup script and make it executable
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 10000

CMD ["/usr/local/bin/startup.sh"]