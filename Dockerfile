FROM maven:3.8-openjdk-17 AS build
COPY . /app
WORKDIR /app
RUN mvn clean package -DskipTests

FROM tomcat:9.0-jdk17-openjdk
# Deploy application as ROOT.war
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Reconfigure Tomcat to bind to Render's dynamic PORT environment variable
ENV PORT=10000
EXPOSE 10000
RUN sed -i 's/port="8080"/port="${port.container:-10000}"/g' /usr/local/tomcat/conf/server.xml

CMD ["catalina.sh", "run"]