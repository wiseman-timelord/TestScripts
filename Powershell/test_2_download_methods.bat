@echo off
mode 70,80

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
goto CHANGE_DIR

:ADMIN_PROMPT
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

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
powershell -ExecutionPolicy Bypass -File test_download_method.ps1
@echo off
echo.
echo.


:EXIT
set /p input=(Press Enter to Finish...)
