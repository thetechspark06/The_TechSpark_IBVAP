@echo off
setlocal enabledelayedexpansion
title IBVAP - One-Click Setup for New PC
color 0A

:: Always navigate to the folder where this batch file is located
cd /d "%~dp0"

echo ====================================================================
echo      IBVAP - Intelligent Border Analytics Platform Setup
echo ====================================================================
echo.

:: 1. Check if user is running from inside an unextracted zip
echo %~dp0 | findstr /i "Temp" >nul
if %errorlevel% equ 0 (
    echo [ERROR] You are running this file from INSIDE the ZIP file!
    echo.
    echo Please EXTRACT the zip first:
    echo   1. Right-click "IBVAP_Portable.zip"
    echo   2. Click "Extract All..."
    echo   3. Open the extracted folder and run SETUP_NEW_PC.bat again.
    echo.
    pause
    exit /b 1
)

:: 2. Detect Python executable
set "PY_CMD="

:: Try standard python command
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_CMD=python"
    goto :PYTHON_FOUND
)

:: Try Python Launcher (py)
py -3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_CMD=py -3"
    goto :PYTHON_FOUND
)

:: Search common installation directories
for %%D in (
    "%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
    "C:\Python313\python.exe"
    "C:\Python312\python.exe"
    "C:\Python311\python.exe"
    "C:\Python310\python.exe"
) do (
    if exist "%%~D" (
        set "PY_CMD=%%~D"
        goto :PYTHON_FOUND
    )
)

:PYTHON_NOT_FOUND
echo [ERROR] Python was not detected on your system!
echo.
echo Please install Python (3.10, 3.11, 3.12, or 3.13) from:
echo https://www.python.org/downloads/
echo.
echo ** CRITICAL INSTALLATION STEP **:
echo On the very first screen of the Python installer, check the box:
echo    [x] "Add python.exe to PATH"
echo.
pause
exit /b 1

:PYTHON_FOUND
echo [OK] Python detected:
%PY_CMD% --version
echo.

:: 3. Create Virtual Environment
if not exist "venv\Scripts\activate.bat" (
    echo [1/3] Creating virtual environment 'venv'...
    %PY_CMD% -m venv venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment.
        echo Please ensure Python venv module is available.
        pause
        exit /b 1
    )
    echo [OK] Virtual environment created.
) else (
    echo [1/3] Virtual environment already exists.
)

:: 4. Activate Virtual Environment
echo.
echo [2/3] Activating virtual environment...
call "%~dp0venv\Scripts\activate.bat"
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment.
    pause
    exit /b 1
)

:: 5. Upgrade pip
echo.
echo Updating pip package manager...
python -m pip install --upgrade pip --timeout 60 >nul 2>&1

:: 6. Install PyTorch first (fast CPU wheel to avoid 2.5GB CUDA download timeouts)
echo.
echo [3/3] Installing IBVAP dependencies...
echo Installing PyTorch engine (lightweight CPU build)...
python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu --timeout 120 --retries 5

:: 7. Install Remaining Dependencies
echo.
echo Installing remaining platform requirements...
python -m pip install -r requirements.txt --timeout 120 --retries 5 --no-cache-dir
if errorlevel 1 (
    echo.
    echo [ERROR] Some dependencies failed to install.
    echo Please check your internet connection and try running SETUP_NEW_PC.bat again.
    pause
    exit /b 1
)

echo.
echo ====================================================================
echo      [SUCCESS] IBVAP Environment Setup Completed Successfully!
echo ====================================================================
echo.
echo To start IBVAP anytime, simply double-click "RUN_IBVAP.bat".
echo.
pause
