@echo off
setlocal enabledelayedexpansion
set "base=%CD%"

for /R "%base%" %%f in (*) do (
    set "p=%%f"
    set "p=!p:%base%\=!"
    echo !p!
)
endlocal