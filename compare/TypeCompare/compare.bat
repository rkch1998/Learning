@echo off
setlocal

echo CASP Type Compare Run

echo Available Products:
echo 1: local
echo 2: casp

echo Available Environments:
echo 1: sample
echo 2: fe
echo 3: qa
echo 4: devqa

set /p INPUT=Please Enter Product Number and Environment Number (e.g., 1 1): 

for /f "tokens=1,2" %%a in ("%INPUT%") do (
    set PRODUCT=%%a
    set ENVIRONMENT=%%b
)

set PRODUCT_NAME=
if "%PRODUCT%"=="1" (
    set PRODUCT_NAME=local
) else if "%PRODUCT%"=="2" (
    set PRODUCT_NAME=casp
) else (
    echo Invalid product choice
    goto End
)

set ENVIRONMENT_NAME=
if "%ENVIRONMENT%"=="1" (
    set ENVIRONMENT_NAME=sample
) else if "%ENVIRONMENT%"=="2" (
    set ENVIRONMENT_NAME=fe
) else if "%ENVIRONMENT%"=="3" (
    set ENVIRONMENT_NAME=qa
) else if "%ENVIRONMENT%"=="4" (
    set ENVIRONMENT_NAME=devqa
) else (
    echo Invalid environment choice
    goto End
)

cls
echo Running comparison on %PRODUCT_NAME% for %ENVIRONMENT_NAME%
call java -jar compare.jar --p=%PRODUCT_NAME% --e=%ENVIRONMENT_NAME%

pause
:End
endlocal
