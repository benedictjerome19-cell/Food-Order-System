@echo off
if "%~1"=="" (
    echo Usage: hash-password.bat ^<your_password^>
    exit /b 1
)
java -cp "target\classes;target\benedictjeromemart\WEB-INF\lib\*" com.benedictjeromemart.util.PasswordUtil "%~1"
