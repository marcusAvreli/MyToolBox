@echo off
rem https://stackoverflow.com/questions/17724449/batch-script-to-find-a-folder-inside-sub-folders-and-get-folder-path
for /d /r "c:\Users\User" %%a in (*) do if /i "%%~nxa"=="yourfoldername" set "folderpath=%%a"
echo "%folderpath%"