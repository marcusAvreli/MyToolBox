@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "base=%CD%"
set "tmpfile=%TEMP%\file_dates.tmp"

rem ============================================================
rem Configuration
rem ============================================================

set "showDates=false"

rem true  = do not show completely empty directories
rem false = show completely empty directories as \<empty_dir>
set "skipEmptyDirectories=false"

rem Directory names to skip at any depth
set "skipDirs=scss dist .git node_modules .angular .vscode"

rem ============================================================

> "%tmpfile%" type nul

call :walk "%base%"

sort "%tmpfile%"
del "%tmpfile%" >nul 2>&1

echo Done
endlocal
exit /b


:walk
set "curr=%~1"

rem ============================================================
rem Write files in current directory
rem ============================================================

for %%f in ("%curr%\*") do (
    if exist "%%~ff" (
        if /I not "%%~af"=="d" (
            set "full=%%~ff"
            set "rel=!full:%base%\=!"

            if /I "!showDates!"=="true" (
                set "moddate=%%~tf"
                set "created="

                for /f "delims=" %%L in (
                    'dir /a:-d /tc "%%~ff" ^| findstr /R "^[ ]*[0-9]"'
                ) do (
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


rem ============================================================
rem Process child directories
rem ============================================================

for /D %%d in ("%curr%\*") do (

    set "skipDir="

    rem --------------------------------------------------------
    rem Skip configured directory names
    rem --------------------------------------------------------

    for %%s in (%skipDirs%) do (
        if /I "%%~nxd"=="%%s" (
            set "skipDir=1"
        )
    )


    rem --------------------------------------------------------
    rem Process directory when it is not explicitly skipped
    rem --------------------------------------------------------

    if not defined skipDir (

        set "directoryHasContent="

        rem Check whether directory contains any file or directory
        for /f "delims=" %%E in (
            'dir /b /a "%%~fd" 2^>nul'
        ) do (
            set "directoryHasContent=1"
        )


        rem ----------------------------------------------------
        rem Completely empty directory
        rem ----------------------------------------------------

        if not defined directoryHasContent (

            if /I "!skipEmptyDirectories!"=="false" (

                set "full=%%~fd"
                set "rel=!full:%base%\=!"

                if /I "!showDates!"=="true" (
                    set "moddate=%%~td"
                    >> "%tmpfile%" echo                 !moddate!    !rel!\^<empty_dir^>
                ) else (
                    >> "%tmpfile%" echo !rel!\^<empty_dir^>
                )
            )

        ) else (

            rem ------------------------------------------------
            rem Non-empty directory: recurse normally
            rem ------------------------------------------------

            call :walk "%%~fd"
        )
    )
)

exit /b