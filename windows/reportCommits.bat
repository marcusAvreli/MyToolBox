@echo off

setlocal EnableDelayedExpansion
set "PROD_TAG=" 

for /f "delims=" %%t in ('git tag --list "*-prod" --sort=-creatordate') do (
  set "PROD_TAG=%%t"
  goto found
) 

:found

echo From prod tag: %PROD_TAG% 1>&2
git log "%PROD_TAG%..HEAD" "--date=format-local:%%Y-%%m-%%d %%H:%%M:%%S" "--pretty=format:COMMIT_DATA|%%H|%%h|%%ad|%%an|%%s" --name-status > "%TEMP%\git_prod_log.txt"

echo commit_hash,commit_short,date,author,message,file_status,file_name 

for /f "usebackq delims=" %%L in ("%TEMP%\git_prod_log.txt") do (

  set "LINE=%%L"

 

  if "!LINE:~0,12!"=="COMMIT_DATA|" (

    for /f "tokens=1,2,3,4,5,* delims=|" %%a in ("!LINE!") do (

      set "COMMIT_HASH=%%b"

      set "COMMIT_SHORT=%%c"

      set "COMMIT_DATE=%%d"

      set "COMMIT_AUTHOR=%%e"

      set "COMMIT_MSG=%%f"

    )

  ) else (

    for /f "tokens=1,* delims=  " %%a in ("!LINE!") do (

      if not "%%b"=="" (

        echo "!COMMIT_HASH!","!COMMIT_SHORT!","!COMMIT_DATE!","!COMMIT_AUTHOR!","!COMMIT_MSG!","%%a","%%b"

      )

    )

  )

)
del "%TEMP%\git_prod_log.txt" >nul 2>&1