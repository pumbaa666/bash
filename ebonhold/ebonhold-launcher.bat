@echo off
rem Launcher for WoW-Ebonhold.
rem It runs the update script and launches the game executable.
rem Author: Pumbaa
rem Github: https://github.com/pumbaa666/
rem Website: https://pumbaa.ch
rem License: MIT License

setlocal

rem Check if python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH.
    echo Run install-python.bat to set up the Python environment and install dependencies or install it manually :
    echo Install Python 3.8.10 from the official website: https://www.python.org/downloads/release/python-3810/
    echo Python 3.8.10 is the latest version compatible with Windows 7, but also works on Windows 10/11.

    pause
    exit /b 1
)

rem Run the update script (if it exists), which will handle downloading and copying the latest game files.
set "GAME_LOCATION=."
set "UPDATE_SCRIPT=update-ebonhold.py"
if exist "%UPDATE_SCRIPT%" (
    echo Running update script, it may take a while...
    python "%UPDATE_SCRIPT%" --game-location="%GAME_LOCATION%"
) else (
    echo Warning: Update script not found. Skipping update step.
)

rem Launch the game executable.
set "GAME_EXECUTABLE=WoW.exe"
if exist "%GAME_LOCATION%\%GAME_EXECUTABLE%" (
    echo Launching WoW-Ebonhold...
    start "" "%GAME_LOCATION%\%GAME_EXECUTABLE%"
) else (
    echo Error: WoW-Ebonhold executable not found. Please check the path and try again.
    pause
)
endlocal
