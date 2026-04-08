@echo off
setlocal EnableDelayedExpansion

set "base=%CD%"
set "tmpfile=%TEMP%\file_dates.tmp"
set "showDates=false"

rem Directory names to skip at any depth
set "skipDirs=scss dist .git node_modules .angular .vscode"

> "%tmpfile%" type nul

call :walk "%base%"

sort "%tmpfile%"
del "%tmpfile%" >nul 2>&1

echo Done
endlocal
exit /b


:walk
set "curr=%~1"

rem Write files in current directory
for %%f in ("%curr%\*") do (
    if exist "%%~ff" (
        if /I not "%%~af"=="d" (
            set "full=%%~ff"
            set "rel=!full:%base%\=!"

            if /I "!showDates!"=="true" (
                set "moddate=%%~tf"

                set "created="
                for /f "delims=" %%L in ('dir /a:-d /tc "%%~ff" ^| findstr /R "^[ ]*[0-9]"') do (
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
)

rem Recurse only into directories that are not skipped
for /D %%d in ("%curr%\*") do (
    set "skipDir="
    for %%s in (%skipDirs%) do (
        if /I "%%~nxd"=="%%s" set "skipDir=1"
    )
    if not defined skipDir (
        call :walk "%%~fd"
    )
)

exit /b