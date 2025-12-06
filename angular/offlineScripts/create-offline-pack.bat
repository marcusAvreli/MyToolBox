@echo off
setlocal enabledelayedexpansion

REM ---------------------------------------
REM 1) Clean and install dependencies online
REM ---------------------------------------
echo [1/3] Installing project dependencies...
npm ci || exit /b 1

REM ---------------------------------------
REM 2) Generate a list of ALL dependencies
REM ---------------------------------------
echo [2/3] Building dep list...
npm ls --all --parseable > deps.txt

REM ---------------------------------------
REM 3) Pack every dependency into offline-pack/
REM ---------------------------------------
echo [3/3] Packing tarballs...
mkdir offline-pack 2>nul

for /f "usebackq tokens=*" %%A in ("deps.txt") do (
    pushd "%%A" 2>nul
    if exist package.json (
        echo Packing %%A
        npm pack --silent
        for %%F in (*.tgz) do move /Y "%%F" "%~dp0offline-pack" >nul
    )
    popd 2>nul
)

echo Done. Tarballs are in offline-pack\
endlocal
