@echo off
rem https://stackoverflow.com/questions/44335008/counting-number-of-directories
rem https://stackoverflow.com/questions/6354240/have-bat-file-continue-after-it-runs-a-command
rem https://stackoverflow.com/questions/18466830/how-to-compare-two-lists-using-cli
rem https://stackoverflow.com/questions/155932/how-do-you-loop-through-each-line-in-a-text-file-using-a-windows-batch-file
setlocal enabledelayedexpansion
start /b /wait cmd /C "npm i ../uiComponentsLight/dist/ui-components-light-0.0.0.tgz"
if !errorlevel! neq 0 exit /b !errorlevel!


echo Starting angular server..
ng serve
:finish
pause
