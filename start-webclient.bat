@echo off
rem Launch the local u3dconv drag-and-drop UI and open it in the browser.
setlocal
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo.
    echo   [!] Setup is not complete.
    echo       Run install-dependencies.bat first, then start this again.
    echo.
    pause
    exit /b 1
)

".venv\Scripts\python.exe" -m u3dconv.web --port 8765
if errorlevel 1 pause
