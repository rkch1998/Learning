@echo off
setlocal

call java -jar execution.jar --spring.profiles.active=pg tenant

pause
:End
endlocal
