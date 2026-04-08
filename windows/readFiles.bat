@echo off
setlocal EnableDelayedExpansion

set "maxFiles=5"
set "outputFile=combined_output.txt"
set "parentOnly=true"
set /a count=0

if exist "%outputFile%" del "%outputFile%"

for %%D in ("%CD%") do (
    set "currentDirName=%%~nxD"
)

for %%F in (*) do (
    if /I not "%%~nxF"=="%outputFile%" (
        set /a count+=1
        if !count! LEQ %maxFiles% (
            if /I "%parentOnly%"=="true" (
                >> "%outputFile%" echo !currentDirName!\%%~nxF
            ) else (
                >> "%outputFile%" echo %CD%\%%~nxF
            )
            >> "%outputFile%" type "%%F"
            >> "%outputFile%" echo(
        )
    )
)

echo Done. Output written to "%outputFile%"
endlocal