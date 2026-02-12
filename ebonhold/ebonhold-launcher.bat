@rem Launcher for WoW-Ebonhold.
@rem It runs the update script and launches the game executable.
@echo off
setlocal

rem Check if python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH.
    echo For Windows 7 : Install Python 3.8.10 from the official website: https://www.python.org/downloads/release/python-3810/
    echo For Windows 10/11 : Install latest from the official website: https://www.python.org/downloads/

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
)
endlocal