for /f "delims=" %%A /i in (beforeInstall.txt) do @find /i %%A "afterInstall.txt" >nul2>nul || echo.%%A>>list3.txt
afterInstall
rem @find %%A "afterInstall.txt" >nul2>nul || echo.%%A>>list3.txt