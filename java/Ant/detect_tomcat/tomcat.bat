@echo off
setlocal enabledelayedexpansion

set "firstPID="
set "mismatch="

for /f "tokens=5" %%A in ('netstat -a -n -o ^| findstr :%PORT% ^| findstr LISTENING') do (

rem ===for /f "tokens=5" %%A in ('netstat -a -n -o ^| findstr :8080') do (
    if not defined firstPID (
        set "firstPID=%%A"
    ) else (
        if not "%%A"=="!firstPID!" set "mismatch=1"
    )
)

if not defined firstPID (
    echo No process found on port 8080
    exit /b 1
)

if defined mismatch (
    echo Multiple different PIDs found
    exit /b 1
)

rem === all PIDs identical ===
echo !firstPID!
exit /b 0