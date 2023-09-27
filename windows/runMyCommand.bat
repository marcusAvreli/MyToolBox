@echo off
rem https://stackoverflow.com/questions/44335008/counting-number-of-directories
rem https://stackoverflow.com/questions/6354240/have-bat-file-continue-after-it-runs-a-command
rem https://stackoverflow.com/questions/18466830/how-to-compare-two-lists-using-cli
rem https://stackoverflow.com/questions/155932/how-do-you-loop-through-each-line-in-a-text-file-using-a-windows-batch-file
del diff.txt
for /F %%a in ('
    dir /B /A:D "node_modules\*" ^| find /C /V ""
') do (
    set beforeInstallCount=%%a
)
echo number of directories before install: %beforeInstallCount%
dir /B /AD "node_modules" > beforeInstall.txt
start /b /wait cmd /C "npm install"

for /F %%a in ('
    dir /B /A:D "node_modules\*" ^| find /C /V ""
') do (
    set afterInstallCount=%%a
)
dir /B /AD "node_modules" > afterInstall.txt
echo number of directories after install: %afterInstallCount%
SETLOCAL EnableDelayedExpansion

for /f "delims=" %%A in (afterInstall.txt) do @find "%%A" "beforeInstall.txt" >nul2>nul || echo.%%A>>diff.txt 

if exist diff.txt (
	for /f %%C in ('Find /V /C "" ^< "diff.txt"') do set delta=%%C
		echo delta,%delta%

	if not delta ==[] (
		if delta gtr 0 (
			
			for /f "tokens=1*" %%A in (diff.txt) do ( 	 xcopy /e /k /h /i /y "node_modules\%%A" "dst\node_modules\%%A" )
			
			rem (@echo.%%A)
			rem for /F "eol=; tokens=2,3* delims=," %i in (myfile.txt) do @echo %i %j %k
		)
	)
)

if beforeInstallCount equ afterInstallCount (
	echo echo 
)

if beforeInstallCount gtr afterInstallCount(
	set diff = 1
	rem echo files removed: %%diff
	echo ok1
)
if afterInstallCount gtr beforeInstallCount(
	set diff = 2
	rem echo files added: %%diff
	echo ok2
)

rem for /f "delims=" %A in (list1.txt) do @find "%A" "list2.txt" >nul2>nul || echo.%A>>list3.txt
rem for /f "delims=" %A in (afterInstall.txt) do @find "%A" "beforeInstall.txt" >nul2>nul || echo.%A>>diff.txt
rem @find %%A "afterInstall.txt" >nul2>nul || echo.%%A>>list3.txt


