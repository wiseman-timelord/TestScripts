@echo off
mode con cols=60 lines=30

:: Run Script
echo Starting PowerShell Script...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\test_wget.ps1"
echo.
echo ...PowerShell Script Exited!

:: Exit Launcher
echo.
pause