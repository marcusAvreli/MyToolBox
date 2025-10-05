rem Lists all files with their last modified dates.

rem Writes them to a temp file.

rem Sorts them by date (ascending).

rem Displays the sorted result.



@echo off
setlocal enabledelayedexpansion
set "base=%CD%"
set "tmpfile=%TEMP%\file_dates.tmp"

rem Clear temp file
> "%tmpfile%" echo.

rem Collect file paths with modification dates
for /R "%base%" %%f in (*) do (
    for %%a in ("%%f") do (
        set "moddate=%%~ta"
        rem Replace the base path with a relative path
        set "p=%%f"
        set "p=!p:%base%\=!"
        rem Save date, time, and path (tab-separated)
        >> "%tmpfile%" echo !moddate!    !p!
    )
)

rem Sort by date/time ascending
sort "%tmpfile%"

rem Optional: delete temp file
del "%tmpfile%" >nul 2>&1

endlocal
pause