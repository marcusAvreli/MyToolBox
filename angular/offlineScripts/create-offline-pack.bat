@echo off
setlocal enabledelayedexpansion

REM ====================================================
REM CONFIGURATION
REM ====================================================
set PROJECT_DIR=%CD%\testAngular
set OFFLINE_REGISTRY_DIR=%CD%\verdaccio-cache
set STORAGE_DIR=%OFFLINE_REGISTRY_DIR%\storage
set TARBALL_DIR=%OFFLINE_REGISTRY_DIR%\tarballs
set REGISTRY_URL=http://127.0.0.1:4873

REM ====================================================
echo ====================================================
echo STEP 0: Verify Node and npm
echo ====================================================
call node -v
call npm -v

REM ====================================================
echo ====================================================
echo STEP 1: Install Verdaccio if missing
echo ====================================================
call verdaccio --version >nul 2>&1
if errorlevel 1 (
    echo Verdaccio not found. Installing globally...
    call npm install -g verdaccio@6.2.3
) else (
    echo Verdaccio already installed.
)
call verdaccio --version

REM ====================================================
echo ====================================================
echo STEP 2: Prepare offline registry folders
echo ====================================================
if exist "%OFFLINE_REGISTRY_DIR%" rd /s /q "%OFFLINE_REGISTRY_DIR%"
mkdir "%STORAGE_DIR%"
mkdir "%TARBALL_DIR%"

REM ====================================================
echo ====================================================
echo STEP 3: Start Verdaccio registry in background
echo ====================================================
REM Find full path to Verdaccio executable on Windows
for /f "delims=" %%V in ('where verdaccio') do set VERDACCIO_CMD=%%V

REM Start Verdaccio in a new window
echo %VERDACCIO_CMD%
echo %STORAGE_DIR%
start "" cmd /c "\"%VERDACCIO_CMD%\" --listen 4873 --storage \"%STORAGE_DIR%\""

echo Waiting 5 seconds for registry to start...
call timeout /t 5 >nul

REM ====================================================
echo ====================================================
echo STEP 4: Point npm to local registry
echo ====================================================
cd "%PROJECT_DIR%"
call npm set registry %REGISTRY_URL%
echo Current npm registry: 
call npm get registry

REM ====================================================
echo ====================================================
echo STEP 5: Install project dependencies to populate offline cache
echo ====================================================
REM This will request all packages from npm and cache them in Verdaccio
call npm install --ignore-scripts --no-audit --no-fund
if errorlevel 1 (
    echo FATAL: npm install failed. Aborting.
    goto :end
)

REM ====================================================
echo ====================================================
echo STEP 6: Tarball backup (optional)
echo ====================================================
REM Create tarballs for extra safety
mkdir "%OFFLINE_REGISTRY_DIR%\tarballs" 2>nul
for /d %%D in (node_modules\*) do (
    call npm pack "%%D" --silent
    if exist *.tgz move /Y *.tgz "%OFFLINE_REGISTRY_DIR%\tarballs" >nul
)

REM ====================================================
echo ====================================================
echo STEP 7: Offline cache ready
echo ====================================================
echo Offline registry directory: %OFFLINE_REGISTRY_DIR%
echo Copy this entire folder to the offline machine.

echo.
echo On offline machine:
echo    1. Start Verdaccio:
echo          verdaccio --listen 4873 --storage "%OFFLINE_REGISTRY_DIR%\storage"
echo    2. Set npm registry:
echo          npm set registry %REGISTRY_URL%
echo    3. Run npm ci in project directory
echo    4. ng serve should work offline
echo ====================================================

:end
endlocal


