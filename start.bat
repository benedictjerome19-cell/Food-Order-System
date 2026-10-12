@echo off
echo ========================================================
echo Building and Starting BenedictJeromeMart...
echo ========================================================
call mvn clean package -DskipTests
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed. Please check the logs.
    exit /b %ERRORLEVEL%
)
copy /y target\benedictjeromemart.war tomcat\webapps\benedictjeromemart.war
copy /y target\benedictjeromemart.war tomcat\webapps\Food-Order-System.war
copy /y target\benedictjeromemart.war tomcat\webapps\ROOT.war
call tomcat\bin\startup.bat
echo ========================================================
echo Project started successfully!
echo Open: http://localhost:8080/benedictjeromemart/login.jsp
echo ========================================================
