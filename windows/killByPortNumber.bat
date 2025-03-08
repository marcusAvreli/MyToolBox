@echo off
rem https://stackoverflow.com/questions/41716833/getting-an-error-listen-eaddrinuse-3000-on-windows-machine
FOR /F "tokens=5 delims= " %%P IN ('netstat -a -n -o ^| findstr :3002') DO IF NOT %%P==0 (TaskKill.exe /PID %P /F)