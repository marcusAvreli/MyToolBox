rem Lists all files with their last modified dates.

rem Writes them to a temp file.

rem Sorts them by date (ascending).

rem Displays the sorted result.


@echo off
setlocal EnableDelayedExpansion

set "base=%CD%"
set "tmpfile=%TEMP%\file_dates.tmp"
set "showDates=false"

rem Top-level directory names to skip (space-separated)
set "skipDirs=scss dist .git"

rem Clear temp file
> "%tmpfile%" type nul

rem Collect file paths with optional creation + modification dates
for /R "%base%" %%f in (*) do (
    set "rel=%%f"
    set "rel=!rel:%base%\=!"

    rem Extract first directory name from relative path
    set "top="
    for /f "tokens=1 delims=\" %%d in ("!rel!") do set "top=%%d"

    rem Decide whether to skip this file
    set "skipFile="
    for %%s in (%skipDirs%) do (
        if /I "!top!"=="%%s" set "skipFile=1"
    )

    if not defined skipFile (
        if /I "!showDates!"=="true" (
            rem Modified date
            set "moddate=%%~tf"

            rem Creation date from DIR /TC
            set "created="
            for /f "delims=" %%L in ('dir /a:-d /tc "%%f" ^| findstr /R "^[ ]*[0-9]"') do (
                set "line=%%L"
                for /f "tokens=1,2" %%x in ("!line!") do (
                    set "created=%%x %%y"
                )
            )

            >> "%tmpfile%" echo !created!    !moddate!    !rel!
        ) else (
            >> "%tmpfile%" echo !rel!
        )
    )
)

rem Sort output
sort "%tmpfile%"

rem Optional: delete temp file
del "%tmpfile%" >nul 2>&1

endlocal
pause