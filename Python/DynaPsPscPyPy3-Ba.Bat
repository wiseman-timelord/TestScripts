@echo off

:: Initialization
mode con cols=60 lines=30
title DynaPsPscPyPy3-Ba
color 0E
set cols=60
echo.
echo DynaPsPscPyPy3-Ba Started...
timeout /t 2 /nobreak >nul

:: Artwork
set "header60====================( DynaPsPscPyPy3-Ba )===================="
set "header70==========================( DynaPsPscPyPy3-Ba )========================"
set "header50===============( DynaPsPscPyPy3-Ba )==============="

:: Function to list scripts
:generateMenu
set i=0
setlocal EnableDelayedExpansion
for %%f in (*.ps1, *.py) do (
    set /a i+=1
    if "%%~xf"==".ps1" (
        set "scriptName[!i!]=PS: %%~nxf"
    ) else if "%%~xf"==".py" (
        set "scriptName[!i!]=PY: %%~nxf"
    )
)

if %i%==0 (
    echo No .Ps1/.Py Scripts Found!
    timeout /t 2 /nobreak >nul
    goto end
)

:: Main Menu
:menu
cls
echo.
if "%cols%"=="60" echo %header60%
if "%cols%"=="70" echo %header70%
if "%cols%"=="50" echo %header50%
echo.
echo                      Scripts Found: %i%
echo.

for /l %%x in (1,1,%i%) do (
    echo               %%x. !scriptName[%%x]!
)

echo.
echo.

:: User choice
set /p choice=Select, Script=1-#, Refresh=R, Window=W, Quit=X: 
if /i "%choice%"=="x" goto end
if /i "%choice%"=="r" goto generateMenu
if /i "%choice%"=="w" goto changeWindowSize

:: Validate choice
set "selectedScript=!scriptName[%choice%]!"
if "!selectedScript!"=="" (
    echo Invalid choice.
    echo.
	timeout /t 2 /nobreak >nul
    goto menu
)

:: Extracting script file name and type from the selection
set "scriptFile=!selectedScript:~4!"
set "scriptType=!selectedScript:~0,2!"

:: Determine script type and execute
echo.
echo Launching !scriptType! Script: !scriptFile!
echo.
timeout /t 2 /nobreak >nul
if "!scriptType!"=="PS" (
    where pwsh >nul 2>&1 && (
        echo Pwsh Found, Using Pwsh...
        echo.
		timeout /t 2 /nobreak >nul
        pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "!scriptFile!"
    ) || (
        where powershell >nul 2>&1 && (
            echo Pwsh Missing, Using Powershell...
            echo.
			timeout /t 2 /nobreak >nul
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!scriptFile!"
        ) || (
            echo Powershell Missing, Critical Error!
            echo.
			timeout /t 2 /nobreak >nul
            goto end
        )
    )
) else if "!scriptType!"=="PY" (
    where python3 >nul 2>&1 && (
        echo Python3 Found, Using Python3...
        echo.
		timeout /t 2 /nobreak >nul
        python3 "!scriptFile!"
    ) || (
        where python >nul 2>&1 && (
            echo Python3 Missing, Using Python...
            echo.
			timeout /t 2 /nobreak >nul
            python "!scriptFile!"
        ) || (
            echo Python Missing, Critical Error!
            echo.
			timeout /t 2 /nobreak >nul
            goto end
        )
    )
)


:: Return to menu or exit
echo.
echo ...Script Exited.
echo.
timeout /t 2 /nobreak >nul
:retryExitChoice
echo Select, Main Menu = M, Exit Program = X
set /p exitChoice=Option: 
if /i "%exitChoice%"=="m" goto menu
if /i "%exitChoice%"=="x" goto end
echo Invalid choice.
echo.
timeout /t 2 /nobreak >nul
goto retryExitChoice

:: Change Window Size
:changeWindowSize
if "%cols%"=="60" (
    set cols=50
    set lines=40
) else if "%cols%"=="50" (
    set cols=70
    set lines=30
) else (
    set cols=60
    set lines=30
)
mode con cols=%cols% lines=%lines%
goto menu

:end
echo.
echo ...Launcher Script Finished.
echo.
pause
