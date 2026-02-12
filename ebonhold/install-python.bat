@echo off
rem This script checks if Python, pip and requests are installed and provides instructions for installation if they're not found.
rem It also attempts to install the requests package if it's missing.
rem If a python installer is included in the same directory, it will launch it and install Python and dependencies.
rem Author: Pumbaa
rem Github: https://github.com/pumbaa666/
rem Website: https://pumbaa.ch
rem License: MIT License

setlocal

set "PYTHON_VERSION_MAJOR=3.8"
set "PYTHON_VERSION_FULL=%PYTHON_VERSION_MAJOR%.10"

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "OS_ARCH=-amd64"
) else (
    set "OS_ARCH="
)

set "PYTHON_INSTALLER_NAME=python-%PYTHON_VERSION_FULL%%OS_ARCH%.exe"

rem Check if python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Python is not installed or not in PATH.
    if exist "%PYTHON_INSTALLER_NAME%" (
        echo Found Python installer: %PYTHON_INSTALLER_NAME%. Launching installer...
        echo Please follow the installer instructions to install Python %PYTHON_VERSION_FULL% and make sure to check the option to add Python to PATH during installation.
        echo This script will resume after the installer is closed, and will check again for Python and pip before proceeding to install dependencies.
        start /wait "" "%PYTHON_INSTALLER_NAME%"

        rem After installation, try to find the python executable in the registry and set it to PYTHON_EXE variable.
        rem to avoid reloading PATH or restarting this script and possibly entering an infinite loop.
        for /f "tokens=2*" %%A in (
            'reg query "HKLM\Software\Python\PythonCore\%PYTHON_VERSION_MAJOR%\InstallPath" /ve 2^>nul'
        ) do set "PYTHON_EXE=%%Bpython.exe"

        if not defined PYTHON_EXE (
            for /f "tokens=2*" %%A in (
                'reg query "HKCU\Software\Python\PythonCore\%PYTHON_VERSION_MAJOR%\InstallPath" /ve 2^>nul'
            ) do set "PYTHON_EXE=%%Bpython.exe"
        )

        if not defined PYTHON_EXE (
            echo Failed to install or find Python executable. Please install Python %PYTHON_VERSION_FULL% manually from the official website: https://www.python.org/downloads/release/python-%PYTHON_VERSION_FULL%/
            echo and then restart this script.
            pause
            exit /b 1
        )
    ) else (
        echo Install Python 3.8.10 from the official website: https://www.python.org/downloads/release/python-3810/
        echo Python 3.8.10 is the latest version compatible with Windows 7, but also works on Windows 10/11.
        pause
        exit /b 1
    )
) else (
    echo Python is installed.
)

if not exist venv (
    python -m venv venv
    if errorlevel 1 (
        echo Error: Failed to create Python virtual environment.
        pause
        exit /b 1
    )
)
venv\Scripts\python -m pip install --upgrade pip >nul 2>&1 || exit /b 1
venv\Scripts\python -m pip install requests --disable-pip-version-check >nul 2>&1 || exit /b 1
venv\Scripts\python -c "import requests" >nul 2>&1 || exit /b 1

echo Python environment is set up correctly. You can now run the ebonhold-launcher.bat to update and launch the game.

endlocal
