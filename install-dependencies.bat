@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo   u3dconv - dependency installer
echo   ------------------------------
echo.

rem The shipped pyarmor_runtime.pyd is compiled against python313.dll,
rem so this build loads on Python 3.13 only. Other versions must be rejected
rem here rather than failing later inside pip.
set "NEED=3.13"

rem ---- 1. locate a Python 3.13 interpreter ------------------------------
set "PY="
where py >nul 2>&1
if not errorlevel 1 (
    py -3.13 -c "import sys" >nul 2>&1
    if not errorlevel 1 set "PY=py -3.13"
)
if not defined PY (
    where python >nul 2>&1
    if not errorlevel 1 (
        python -c "import sys; raise SystemExit(0 if sys.version_info[:2]==(3,13) else 1)" >nul 2>&1
        if not errorlevel 1 set "PY=python"
    )
)

if not defined PY (
    rem Report whatever Python was found, so the fix is obvious.
    set "FOUND="
    where py >nul 2>&1
    if not errorlevel 1 (
        for /f "delims=" %%v in ('py -3 -c "import sys; print('.'.join(map(str, sys.version_info[:2])))" 2^>nul') do set "FOUND=%%v"
    )
    if not defined FOUND (
        where python >nul 2>&1
        if not errorlevel 1 (
            for /f "delims=" %%v in ('python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))" 2^>nul') do set "FOUND=%%v"
        )
    )
    echo   [x] Python %NEED% is required and was not found.
    echo.
    if defined FOUND (
        echo       Detected Python !FOUND!, which cannot run this build.
        echo.
    )
    echo       The compiled runtime in this package only loads on Python %NEED%.
    echo       Newer versions such as 3.14 or 3.15 will fail with a text
    echo       encoding error, and their dependencies have no prebuilt
    echo       wheels, so pip tries to compile them from source.
    echo.
    echo       Install Python %NEED% from
    echo           https://www.python.org/downloads/
    echo       and tick "Add python.exe to PATH" during setup.
    echo.
    echo       Both versions can coexist; this installer uses "py -3.13".
    echo.
    pause
    exit /b 1
)

rem ---- 2. confirm the version -------------------------------------------
for /f "delims=" %%v in ('%PY% -c "import sys; print('.'.join(map(str, sys.version_info[:2])))"') do set "PYVER=%%v"
echo   [1/3] Python !PYVER! found

rem ---- 3. virtual environment -------------------------------------------
rem A venv made by a different interpreter cannot load the runtime, so it is
rem rebuilt rather than reused.
set "RECREATE="
if exist ".venv\Scripts\python.exe" (
    ".venv\Scripts\python.exe" -c "import sys; raise SystemExit(0 if sys.version_info[:2]==(3,13) else 1)" >nul 2>&1
    if errorlevel 1 set "RECREATE=1"
)
if exist ".venv\Scripts\python.exe" (
    if not defined RECREATE (
        echo   [2/3] Reusing existing .venv
    )
) else (
    set "RECREATE=1"
)
if defined RECREATE (
    if not exist ".venv\Scripts\python.exe" (
        echo   [2/3] Creating .venv ...
    ) else (
        echo   [2/3] Rebuilding .venv, it was made by a different Python ...
        rmdir /s /q ".venv" >nul 2>&1
    )
    %PY% -m venv .venv
    if errorlevel 1 (
        echo   [x] Could not create the virtual environment.
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
    echo   [x] Dependency installation failed. See the errors above.
    echo.
    echo       If the log mentions "Microsoft Visual C++ 14.0 is required"
    echo       or "Failed building wheel", the interpreter is the wrong
    echo       version. This build needs Python %NEED% exactly.
    echo.
    pause
    exit /b 1
)

rem ---- 5. verify the tool actually loads --------------------------------
echo.
echo   Verifying install ...
"%VPY%" -c "import u3dconv, UnityPy, PIL, flask, lz4" >nul 2>&1
if errorlevel 1 (
    echo   [x] The tool did not load after installing.
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
