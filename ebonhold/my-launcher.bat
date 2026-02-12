@rem Launcher for WoW-Ebonhold.
@rem It runs the update script and launches the game executable.
@echo off
setlocal

set "UPDATE_SCRIPT=update-ebonhold.py"
if exist "%UPDATE_SCRIPT%" (
    echo Running update script, it may take a while...
    python "%UPDATE_SCRIPT%"
) else (
    echo Warning: Update script not found. Skipping update step.
)

set "GAME_EXECUTABLE=WoW.exe"
if exist "%GAME_EXECUTABLE%" (
    echo Launching WoW-Ebonhold...
    start "" "%GAME_EXECUTABLE%"
) else (
    echo Error: WoW-Ebonhold executable not found. Please check the path and try again.
)
endlocal