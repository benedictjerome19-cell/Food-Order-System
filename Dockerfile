# ==========================================
# Stage 1: Build the WAR file using Maven
# ==========================================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# ==========================================
# Stage 2: Run Tomcat and deploy
# ==========================================
FROM tomcat:9.0-jdk17

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/examples /usr/local/tomcat/webapps/docs

# Explicitly copy and rename the built WAR to ROOT.war for root path access
COPY --from=build /app/target/benedictjeromemart.war /usr/local/tomcat/webapps/ROOT.war

# Copy startup script and make it executable
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 10000

CMD ["/usr/local/bin/startup.sh"]