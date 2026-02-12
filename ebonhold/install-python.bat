@echo off
rem This script checks if Python, pip and requests are installed and provides instructions for installation if they're not found.
rem It also attempts to install the requests package if it's missing.
rem If a python installer is included in the same directory, it will launch it and install Python and dependencies.
rem Author: Pumbaa
rem Github: https://github.com/pumbaa666/
rem Website: https://pumbaa.ch
rem License: MIT License

setlocal

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "OS_ARCH=-amd64"
) else (
    set "OS_ARCH="
)
set "PYTHON_VERSION=3.8.10"
set "PYTHON_INSTALLER_NAME=python-%PYTHON_VERSION%%OS_ARCH%.exe"

rem Check if python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Python is not installed or not in PATH.
    if exist "%PYTHON_INSTALLER_NAME%" (
        start /wait "" "%PYTHON_INSTALLER_NAME%"
    ) else (
        echo Install Python 3.8.10 from the official website: https://www.python.org/downloads/release/python-3810/
        echo Python 3.8.10 is the latest version compatible with Windows 7, but also works on Windows 10/11.
        exit /b 1
    )
) else (
    echo Python is installed.
)

rem Check if pip is installed
python -m pip >nul 2>&1
if errorlevel 1 (
    echo pip is not installed or not in PATH.
    exit /b 1
) else (
    echo pip is installed.
)

rem Check if requests package is installed
python -c "import requests" >nul 2>&1
if errorlevel 1 (
    echo requests package is not installed. Installing it now...

    python -m venv venv
    call venv\Scripts\activate
    python -m pip install --upgrade pip
    python -m pip install requests --disable-pip-version-check
) else (
    echo requests package is already installed.
)

rem Check everything is set up correctly
python --version >nul 2>&1 || exit /b 1
python -m pip --version >nul 2>&1 || exit /b 1
python -c "import requests" >nul 2>&1 || exit /b 1
echo Python environment is set up correctly. You can now run the ebonhold-launcher.bat to update and launch the game.

endlocal
