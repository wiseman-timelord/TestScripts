@echo off
setlocal enabledelayedexpansion

:: Initialization
mode con cols=64 lines=30
color 0E
title Download Test Script
cd /d "%~dp0"
set "FILE_URL=https://archive.torproject.org/tor-package-archive/torbrowser/13.0.9/tor-expert-bundle-windows-x86_64-13.0.9.tar.gz"
set "DOWNLOAD_FOLDER=%~dp0downloads"
set "REPORT_FILE=%~dp0download_report.txt"

:: Create download folder if it doesn't exist
if not exist "%DOWNLOAD_FOLDER%" mkdir "%DOWNLOAD_FOLDER%"

:: Clear previous report file
if exist "%REPORT_FILE%" del "%REPORT_FILE%"

:: Define download methods and file names
set "METHODS=Invoke-WebRequest WebClient Curl"
set "FILE_NAMES[0]=Invoke-WebRequest_File"
set "FILE_NAMES[1]=WebClient_File"
set "FILE_NAMES[2]=Curl_File"
set "COUNT=0"

:: Download the file using different methods
for %%M in (%METHODS%) do (
    call :DOWNLOAD_FILE %%M !FILE_NAMES[%COUNT%]!
    set /a COUNT+=1
)

:: Generate report
call :GENERATE_REPORT

:: End of script
echo.
echo Report generated: %REPORT_FILE%
goto :EOF

:DOWNLOAD_FILE
echo.
echo Downloading with %1...
set "METHOD=%1"
set "FILE_NAME=%2"
set "START_TIME=%time%"

if "%METHOD%"=="Invoke-WebRequest" (
    powershell -Command "Invoke-WebRequest -Uri '%FILE_URL%' -OutFile '%DOWNLOAD_FOLDER%\%FILE_NAME%.tar.gz' -TimeoutSec 60"
) else if "%METHOD%"=="WebClient" (
    powershell -Command "$client = New-Object System.Net.WebClient; $client.DownloadFile('%FILE_URL%', '%DOWNLOAD_FOLDER%\%FILE_NAME%.tar.gz')"
) else if "%METHOD%"=="Curl" (
    curl -L "%FILE_URL%" --output "%DOWNLOAD_FOLDER%\%FILE_NAME%.tar.gz"
)

:: Check if download was successful
if exist "%DOWNLOAD_FOLDER%\%FILE_NAME%.tar.gz" (
    echo %1 download SUCCESSFUL >> "%REPORT_FILE%"
    echo Start Time: %START_TIME%, End Time: %time% >> "%REPORT_FILE%"
) else (
    echo %1 download FAILED >> "%REPORT_FILE%"
    echo Start Time: %START_TIME%, End Time: %time% >> "%REPORT_FILE%"
)
goto :EOF

:GENERATE_REPORT
echo.
echo Generating report...
echo Download Test Report > "%REPORT_FILE%"
echo Test date: %DATE% >> "%REPORT_FILE%"
echo Test time: %TIME% >> "%REPORT_FILE%"
echo URL: %FILE_URL% >> "%REPORT_FILE%"
echo Download location: %DOWNLOAD_FOLDER% >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
for %%M in (%METHODS%) do (
    call :APPEND_REPORT %%M !FILE_NAMES[%COUNT%]!
    set /a COUNT+=1
)
goto :EOF

:APPEND_REPORT
if exist "%DOWNLOAD_FOLDER%\%2.tar.gz" (
    echo Method: %1, File: %2, Status: SUCCESSFUL >> "%REPORT_FILE%"
) else (
    echo Method: %1, File: %2, Status: FAILED >> "%REPORT_FILE%"
)
goto :EOF
