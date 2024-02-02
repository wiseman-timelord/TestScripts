@echo off
setlocal enabledelayedexpansion

:: Initialization
mode con cols=80 lines=30
color 0E
title Curl Download Test Script
cd /d "%~dp0"
set "FILE_URL=https://archive.torproject.org/tor-package-archive/torbrowser/13.0.9/tor-expert-bundle-windows-x86_64-13.0.9.tar.gz"
set "DOWNLOAD_FOLDER=%~dp0downloads"
set "FILE_NAME=tor-expert-bundle-windows-x86_64-13.0.9.tar.gz"
set "REPORT_FILE=%~dp0curl_download_report.txt"

:: Create download folder if it doesn't exist
if not exist "%DOWNLOAD_FOLDER%" mkdir "%DOWNLOAD_FOLDER%"

:: Clear previous report file
if exist "%REPORT_FILE%" del "%REPORT_FILE%"

:: Download the file using curl with retry and resume
echo Downloading with Curl...
echo Test started: %DATE% %TIME% > "%REPORT_FILE%"
set "RETRY_COUNT=0"
set "MAX_RETRIES=10"

:DownloadWithCurl
if %RETRY_COUNT% lss %MAX_RETRIES% (
    echo Attempt %RETRY_COUNT% of %MAX_RETRIES%
    curl -L "%FILE_URL%" --output "%DOWNLOAD_FOLDER%\%FILE_NAME%" -C - --progress-bar || (
        echo Retry %RETRY_COUNT% failed, retrying...
        echo Retry %RETRY_COUNT% failed at %DATE% %TIME% >> "%REPORT_FILE%"
        set /a RETRY_COUNT+=1
        timeout /t 5 >nul
        goto DownloadWithCurl
    )
) else (
    echo Max retries reached. Download failed.
    echo Max retries reached at %DATE% %TIME%. Download failed. >> "%REPORT_FILE%"
    goto EndScript
)

:: Check if download was successful
if exist "%DOWNLOAD_FOLDER%\%FILE_NAME%" (
    echo Download SUCCESSFUL
    echo Download completed successfully at %DATE% %TIME% >> "%REPORT_FILE%"
) else (
    echo Download FAILED
    echo Download failed at %DATE% %TIME% >> "%REPORT_FILE%"
)

:EndScript
echo.
echo Report generated: %REPORT_FILE%
type "%REPORT_FILE%"
pause
