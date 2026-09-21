@echo off
title IBVAP - Intelligent Border Analytics Platform
color 0B

:: Always navigate to the script's own folder
cd /d "%~dp0"

echo ====================================================================
echo      IBVAP - Intelligent Border Analytics Platform Launcher
echo ====================================================================
echo.

:: Check if user is running from inside an unextracted zip
echo %~dp0 | findstr /i "Temp" >nul
if %errorlevel% equ 0 (
    echo [ERROR] You are running this file from INSIDE the ZIP file!
    echo.
    echo Please EXTRACT the zip first:
    echo   1. Right-click "IBVAP_Portable.zip"
    echo   2. Click "Extract All..."
    echo   3. Open the extracted folder and run RUN_IBVAP.bat
    echo.
    pause
    exit /b 1
)

:: Activate virtual environment if present
if exist "venv\Scripts\activate.bat" (
    echo [OK] Activating local virtual environment...
    call "%~dp0venv\Scripts\activate.bat"
)

:: Check Python availability
python --version >nul 2>&1
if %errorlevel% neq 0 (
    py -3 --version >nul 2>&1
    if %errorlevel% equ 0 (
        py -3 run.py
        goto :CHECK_EXIT
    )
    echo [ERROR] Python not found on system PATH.
    echo Please run "SETUP_NEW_PC.bat" first to set up the environment.
    echo.
    pause
    exit /b 1
)

:: Launch the master system
python run.py

:CHECK_EXIT
if %errorlevel% neq 0 (
    echo.
    echo [NOTE] If you encountered an error, please run:
    echo        SETUP_NEW_PC.bat
    echo.
    pause
)
