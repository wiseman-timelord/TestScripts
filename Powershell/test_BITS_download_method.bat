@echo off
mode 70,80
mode con:cols=70 lines=3000

REM INITIATION_SECTION

:: CHECK_ADMIN
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: ACTIVATE_ADMIN
if '%errorlevel%' NEQ '0' (
echo Requesting Administrative privileges...
goto ADMIN_PROMPT
)
echo Administrator mode Active...
echo.
echo.
goto CHECK_BITS

:ADMIN_PROMPT
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

:CHECK_BITS
for /f "tokens=3 delims=: " %%H in ('sc query "BITS" ^| findstr "        STATE"') do (
  set BITSStatus=%%H
)
if "%BITSStatus%"=="1" (
  echo BITS is Disabled. Enable BITS in Services, then start again...
  goto EXIT
)
if "%BITSStatus%"=="3" (
  echo BITS is Manual. Activating BITS!
  net start "BITS"
)
if "%BITSStatus%"=="4" (
  echo BITS is Automatic. BITS already Active.
)
echo.
echo.

:CHANGE_DIR
del "%temp%\getadmin.vbs"
pushd "%CD%"
CD /D "%~dp0"
echo Working directory set... 
echo.
echo.



REM APPLICATION_SECTION


:: EXECUTE_MAIN
cls
@echo on
powershell -ExecutionPolicy Bypass -File test_BITS_download_method.ps1
@echo off
echo.
echo.


:EXIT
set /p input=(Press Enter to Finish...)
