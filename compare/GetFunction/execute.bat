@echo off
setlocal

echo CASP Get Function

echo Available Products:
echo 1: pg
echo 2: sql

echo Available Environments:
echo 1: tenant
echo 2: master
echo 3: admin
echo 4: appdata
echo 5: metadata
echo 6: log

set /p INPUT=Please Enter db Number and Environment Number (e.g., 1 1): 

for /f "tokens=1,2" %%a in ("%INPUT%") do (
    set PRODUCT=%%a
    set ENVIRONMENT=%%b
)

set PRODUCT_NAME=
if "%PRODUCT%"=="1" (
    set PRODUCT_NAME=pg
) else if "%PRODUCT%"=="2" (
    set PRODUCT_NAME=sql
) else (
    echo Invalid db choice
    goto End
)

set ENVIRONMENT_NAME=
if "%ENVIRONMENT%"=="1" (
    set ENVIRONMENT_NAME=tenant
) else if "%ENVIRONMENT%"=="2" (
    set ENVIRONMENT_NAME=master
) else if "%ENVIRONMENT%"=="3" (
    set ENVIRONMENT_NAME=admin
) else if "%ENVIRONMENT%"=="4" (
    set ENVIRONMENT_NAME=appdata
) else if "%ENVIRONMENT%"=="5" (
    set ENVIRONMENT_NAME=metadata
) else if "%ENVIRONMENT%"=="6" (
    set ENVIRONMENT_NAME=log
) else (
    echo Invalid environment choice
    goto End
)

cls
echo Running on %PRODUCT_NAME% for %ENVIRONMENT_NAME%
call java -jar getFunction.jar --spring.profiles.active=%PRODUCT_NAME% %ENVIRONMENT_NAME%

pause
:End
endlocal
