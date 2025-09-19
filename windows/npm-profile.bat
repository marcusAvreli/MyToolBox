@echo off
REM npm-profile.bat
REM Usage: npm-profile [online | offline | toggle | reset | status]
REM If no argument is given, behaves like "status".

SET PROFILE_DIR=C:\npm-profiles
SET NPMRC=%USERPROFILE%\.npmrc

:SHOW_STATUS
IF NOT EXIST "%NPMRC%" (
    ECHO Current npm profile: DEFAULT (no .npmrc)
    FOR /F "tokens=* USEBACKQ" %%i IN (`npm config get registry`) DO SET REG=%%i
    FOR /F "tokens=* USEBACKQ" %%j IN (`npm config get cache`) DO SET CACHE=%%j
    ECHO Active registry: %REG%
    ECHO Cache directory: %CACHE%
    GOTO :EOF
)

FINDSTR /C:"offline=true" "%NPMRC%" >nul 2>&1
IF %ERRORLEVEL%==0 (
    SET PROFILE=OFFLINE
) ELSE (
    SET PROFILE=ONLINE
)

FOR /F "tokens=* USEBACKQ" %%i IN (`npm config get registry`) DO SET REG=%%i
FOR /F "tokens=* USEBACKQ" %%j IN (`npm config get cache`) DO SET CACHE=%%j

ECHO Current npm profile: %PROFILE%
ECHO Active registry: %REG%
ECHO Cache directory: %CACHE%
GOTO :EOF

:MAIN
IF "%~1"=="" GOTO SHOW_STATUS

IF /I "%1"=="status" GOTO SHOW_STATUS

IF /I "%1"=="online" (
    COPY /Y "%PROFILE_DIR%\npmrc-online" "%NPMRC%" >nul
    ECHO Switched npm to ONLINE profile.
    GOTO :EOF
)

IF /I "%1"=="offline" (
    COPY /Y "%PROFILE_DIR%\npmrc-offline" "%NPMRC%" >nul
    ECHO Switched npm to OFFLINE profile.
    GOTO :EOF
)

IF /I "%1"=="toggle" (
    IF NOT EXIST "%NPMRC%" (
        COPY /Y "%PROFILE_DIR%\npmrc-offline" "%NPMRC%" >nul
        ECHO Toggled npm profile: DEFAULT → OFFLINE.
        GOTO :EOF
    )
    FINDSTR /C:"offline=true" "%NPMRC%" >nul 2>&1
    IF %ERRORLEVEL%==0 (
        COPY /Y "%PROFILE_DIR%\npmrc-online" "%NPMRC%" >nul
        ECHO Toggled npm profile: now ONLINE.
    ) ELSE (
        COPY /Y "%PROFILE_DIR%\npmrc-offline" "%NPMRC%" >nul
        ECHO Toggled npm profile: now OFFLINE.
    )
    GOTO :EOF
)

IF /I "%1"=="reset" (
    IF EXIST "%NPMRC%" DEL "%NPMRC%"
    ECHO Reset npm profile to DEFAULT (no .npmrc).
    GOTO :EOF
)

ECHO Invalid option. Usage: npm-profile [online ^| offline ^| toggle ^| reset ^| status]
