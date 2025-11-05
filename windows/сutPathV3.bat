@echo off

rem Store the original code page

for /F "tokens=2 delims==" %%I in ('"chcp"') do set "originalCodePage=%%I"

 

rem Set to UTF-8 encoding

chcp 65001

 

setlocal enabledelayedexpansion

set "base=%CD%"

set "tmpfile=%TEMP%\file_dates.tmp"

 

rem Clear temp file

> "%tmpfile%" echo.

 

rem Collect file paths with modification dates

for /R "%base%" %%f in (*) do (

    rem Get the file extension

    set "ext=%%~xf"

   

    rem Get the date and time for creation and modification

    set "createdDate=%%~tc"

    set "moddate=%%~ta"

 

    rem Reformat creation date to YYYY-MM-DD HH:MM:SS

    for /f "tokens=1,2 delims= " %%d in ("!createdDate!") do (

        set "createdDatePart=%%d"

        set "createdTimePart=%%e"

    )

    for /f "tokens=1-3 delims=/" %%a in ("!createdDatePart!") do (

        set "formattedCreatedDate=%%c-%%a-%%b"

    )

    set "formattedCreatedDate=!formattedCreatedDate! !createdTimePart!"

 

    rem Reformat modification date to YYYY-MM-DD HH:MM:SS

    for /f "tokens=1,2 delims= " %%d in ("!moddate!") do (

        set "modDatePart=%%d"

        set "modTimePart=%%e"

    )

    for /f "tokens=1-3 delims=/" %%a in ("!modDatePart!") do (

        set "formattedModDate=%%c-%%a-%%b"

    )

    set "formattedModDate=!formattedModDate! !modTimePart!"

 

    rem Replace the base path with a relative path

    set "p=%%f"

    set "p=!p:%base%\=!"

 

    rem Save the creation date, modification date, relative path, and extension (tab-separated)

    >> "%tmpfile%" echo !formattedCreatedDate!    !formattedModDate!    !p!    !ext!

)

 

rem Sort by modification date ascending

sort "%tmpfile%"

 

rem Optional: delete temp file

del "%tmpfile%" >nul 2>&1

 

rem Restore the original code page

chcp %originalCodePage%

 

endlocal

pause