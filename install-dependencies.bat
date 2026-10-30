@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo   u3dconv - dependency installer
echo   ------------------------------
echo.

rem ---- 1. locate Python -------------------------------------------------
set "PY="
where py >nul 2>&1
if not errorlevel 1 (
    py -3 -c "import sys" >nul 2>&1
    if not errorlevel 1 set "PY=py -3"
)
if not defined PY (
    where python >nul 2>&1
    if not errorlevel 1 (
        python -c "import sys" >nul 2>&1
        if not errorlevel 1 set "PY=python"
    )
)
if not defined PY (
    echo   [!] Python 3 was not found.
    echo.
    echo       Install Python 3.10 or newer from
    echo           https://www.python.org/downloads/
    echo       and tick "Add python.exe to PATH" during setup.
    echo.
    pause
    exit /b 1
)

rem ---- 2. version check -------------------------------------------------
%PY% -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>&1
if errorlevel 1 (
    echo   [!] Your Python is too old. Version 3.10 or newer is required.
    echo.
    pause
    exit /b 1
)
for /f "delims=" %%v in ('%PY% -c "import sys; print('.'.join(map(str, sys.version_info[:2])))"') do set "PYVER=%%v"
echo   [1/3] Python !PYVER! found

rem ---- 3. virtual environment -------------------------------------------
if exist ".venv\Scripts\python.exe" (
    echo   [2/3] Reusing existing .venv
) else (
    echo   [2/3] Creating .venv ...
    %PY% -m venv .venv
    if errorlevel 1 (
        echo   [!] Could not create the virtual environment.
        pause
        exit /b 1
    )
)
set "VPY=.venv\Scripts\python.exe"

rem ---- 4. dependencies --------------------------------------------------
echo   [3/3] Installing dependencies, this may take a few minutes ...
echo.
"%VPY%" -m pip install --upgrade pip --quiet
"%VPY%" -m pip install -r requirements.txt
if errorlevel 1 (
    echo.
    echo   [!] Dependency installation failed. See the errors above.
    pause
    exit /b 1
)

rem ---- 5. verify the tool actually loads --------------------------------
echo.
echo   Verifying install ...
"%VPY%" -c "import u3dconv, UnityPy, PIL, flask, lz4" >nul 2>&1
if errorlevel 1 (
    echo   [!] The tool did not load after installing.
    echo       See the actual error with:
    echo           .venv\Scripts\python.exe -c "import u3dconv"
    pause
    exit /b 1
)

set "UVER=?"
"%VPY%" -c "import u3dconv,sys; sys.stdout.write(u3dconv.__version__)" > "%TEMP%\u3dconv_ver.txt" 2>nul
if exist "%TEMP%\u3dconv_ver.txt" (
    for /f "usebackq delims=" %%v in ("%TEMP%\u3dconv_ver.txt") do set "UVER=%%v"
    del "%TEMP%\u3dconv_ver.txt" >nul 2>&1
)
echo   Tool loads: u3dconv !UVER! ready
echo.
echo   Done.
echo.
echo     Start the web UI:  start-webclient.bat
echo     Command line:
echo         .venv\Scripts\python.exe -m u3dconv convert "D:\pack" -o out
echo.
pause
