@echo off
rem create dir if not exists
IF exist myDirName ( echo myDirName exists ) ELSE ( mkdir myDirName && echo myDirName created)

rem copy file to created dir
xcopy /y hello.txt myDirName