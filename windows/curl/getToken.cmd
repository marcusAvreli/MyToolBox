@echo off

setlocal EnableExtensions

if "%~1"=="" (
  >&2 echo Usage: get-token.cmd ^<service_name^> ^<environment^>
  exit /b 2
)

if "%~2"=="" (
  >&2 echo Usage: get-token.cmd ^<service_name^> ^<environment^>
  exit /b 2
)

set "SERVICE_NAME=%~1"
set "ENVIRONMENT_NAME=%~2"
set "TOKEN_CONTENT_TYPE=%~3"
set "TOKEN_ACCEPT=%~4"

if not defined TOKEN_CONTENT_TYPE (
  set "TOKEN_CONTENT_TYPE=application/x-www-form-urlencoded"
)

if not defined TOKEN_ACCEPT (
  set "TOKEN_ACCEPT=application/json"
)

for %%I in ("%~dp0..") do (
  set "TOOLS_ROOT=%%~fI"
)

set "JQ_EXE=%TOOLS_ROOT%\bin\jq.exe"
set "LOGIN_JSON=%TOOLS_ROOT%\services\%SERVICE_NAME%\environments\%ENVIRONMENT_NAME%\config\login.json"
set "TOKEN_QUERY=%TOOLS_ROOT%\queries\authentication\getToken.jq"

if not exist "%JQ_EXE%" (
  >&2 echo Required JSON processor was not found.
  exit /b 3
)

if not exist "%LOGIN_JSON%" (
  >&2 echo Authentication configuration was not found.
  exit /b 4
)

if not exist "%TOKEN_QUERY%" (
  >&2 echo Token extraction query was not found.
  exit /b 5
)

set "TMP_PREFIX=%TEMP%\oauth-token-%RANDOM%-%RANDOM%"

"%JQ_EXE%" -r ".clientId // empty" "%LOGIN_JSON%" > "%TMP_PREFIX%-clientId.txt"
"%JQ_EXE%" -r ".clientSecret // empty" "%LOGIN_JSON%" > "%TMP_PREFIX%-clientSecret.txt"
"%JQ_EXE%" -r ".baseUrl // empty" "%LOGIN_JSON%" > "%TMP_PREFIX%-baseUrl.txt"
"%JQ_EXE%" -r ".tokenPath // empty" "%LOGIN_JSON%" > "%TMP_PREFIX%-tokenPath.txt"
"%JQ_EXE%" -r ".scope // empty" "%LOGIN_JSON%" > "%TMP_PREFIX%-scope.txt"

set /p "CLIENT_ID="<"%TMP_PREFIX%-clientId.txt"
set /p "CLIENT_SECRET="<"%TMP_PREFIX%-clientSecret.txt"
set /p "BASE_URL="<"%TMP_PREFIX%-baseUrl.txt"
set /p "TOKEN_PATH="<"%TMP_PREFIX%-tokenPath.txt"
set /p "OAUTH_SCOPE="<"%TMP_PREFIX%-scope.txt"

del /q ^
  "%TMP_PREFIX%-clientId.txt" ^
  "%TMP_PREFIX%-clientSecret.txt" ^
  "%TMP_PREFIX%-baseUrl.txt" ^
  "%TMP_PREFIX%-tokenPath.txt" ^
  "%TMP_PREFIX%-scope.txt" ^
  >nul 2>&1

if not defined CLIENT_ID (
  >&2 echo Authentication client ID is missing.
  exit /b 6
)

if not defined CLIENT_SECRET (
  >&2 echo Authentication client secret is missing.
  exit /b 7
)

if not defined BASE_URL (
  >&2 echo Authentication base URL is missing.
  exit /b 8
)

if not defined TOKEN_PATH (
  >&2 echo Authentication token path is missing.
  exit /b 9
)

if not defined OAUTH_SCOPE (
  >&2 echo Authentication scope is missing.
  exit /b 10
)

curl.exe -sS -X POST "%BASE_URL%%TOKEN_PATH%" ^
  -H "Content-Type: %TOKEN_CONTENT_TYPE%" ^
  -H "Accept: %TOKEN_ACCEPT%" ^
  --data-urlencode "grant_type=client_credentials" ^
  --data-urlencode "client_id=%CLIENT_ID%" ^
  --data-urlencode "client_secret=%CLIENT_SECRET%" ^
  --data-urlencode "scope=%OAUTH_SCOPE%" ^
  | "%JQ_EXE%" -r -f "%TOKEN_QUERY%"

exit /b %ERRORLEVEL%