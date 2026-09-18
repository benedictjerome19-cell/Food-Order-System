FROM maven:3.9-eclipse-temurin-17 AS build
COPY . /app
WORKDIR /app
RUN mvn clean package -DskipTests

FROM tomcat:9.0-jdk17-temurin
# Deploy application as ROOT.war
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Bind Tomcat to Render's default port
RUN sed -i 's/port="8080"/port="10000"/g' /usr/local/tomcat/conf/server.xml
EXPOSE 10000

CMD ["catalina.sh", "run"]