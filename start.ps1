Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Building and Starting BenedictJeromeMart..." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

mvn clean package -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Build failed." -ForegroundColor Red
    exit $LASTEXITCODE
}

Copy-Item -Force target\benedictjeromemart.war tomcat\webapps\benedictjeromemart.war
Copy-Item -Force target\benedictjeromemart.war tomcat\webapps\Food-Order-System.war
Copy-Item -Force target\benedictjeromemart.war tomcat\webapps\ROOT.war

Start-Process -FilePath "$PSScriptRoot\tomcat\bin\startup.bat"

Write-Host "========================================================" -ForegroundColor Green
Write-Host "Project started successfully!" -ForegroundColor Green
Write-Host "Open: http://localhost:8080/benedictjeromemart/login.jsp" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Green
