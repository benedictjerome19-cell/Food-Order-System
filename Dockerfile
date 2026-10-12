# Stage 1: Build the application using Maven
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Deploy to Apache Tomcat
FROM tomcat:9.0-jdk17

# Remove Tomcat's default landing page and apps
RUN rm -rf /usr/local/tomcat/webapps/ROOT
RUN rm -rf /usr/local/tomcat/webapps/examples

# Copy the built WAR file and rename it to ROOT.war
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Disable Tomcat shutdown port to prevent Render health checks hitting port 8005
RUN sed -i 's/port="8005"/port="-1"/g' /usr/local/tomcat/conf/server.xml

# Create and configure the entrypoint script natively inside Linux to avoid Windows CRLF errors
RUN printf '#!/bin/bash\nsed -i "s/port=\\\"8005\\\"/port=\\\"-1\\\"/g" /usr/local/tomcat/conf/server.xml\nsed -i "s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g" /usr/local/tomcat/conf/server.xml\nexec catalina.sh run\n' > /usr/local/tomcat/bin/entrypoint.sh \
    && chmod +x /usr/local/tomcat/bin/entrypoint.sh

# Expose default port
EXPOSE 8080

# Run the entrypoint script on startup
CMD ["/usr/local/tomcat/bin/entrypoint.sh"]