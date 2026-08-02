@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem Angular D3 offline preparation
rem Run this script on the ONLINE machine.
rem
rem Verification flow:
rem
rem   Stage 1 - Online npm ci + build
rem   Stage 2 - Offline npm ci + build
rem   Stage 3 - Offline npm install + build
rem
rem The preparation directory is deleted and recreated on every
rem run:
rem
rem   C:\DEVEL\OFFLINE-PREP
rem ============================================================

set "SOURCE_ROOT=%~dp0.."
for %%I in ("%SOURCE_ROOT%") do set "SOURCE_ROOT=%%~fI"

set "PREP_ROOT=C:\DEVEL\OFFLINE-PREP"
set "STAGING_PROJECT=%PREP_ROOT%\angularD3"
set "OFFLINE_CACHE=%PREP_ROOT%\npm-cache"
set "ONLINE_CACHE=C:\Users\markg\AppData\Local\npm-cache"

set "ARCHIVE=%PREP_ROOT%\angularD3-offline.tar.gz"
set "ARCHIVE_TEMP=%PREP_ROOT%\angularD3-offline.tar.gz.partial"
set "CHECKSUM_FILE=%ARCHIVE%.sha256.txt"

rem ============================================================
rem Initial Node.js check
rem Node.js is also used for elapsed-time calculations.
rem ============================================================

where node >nul 2>&1

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] NODE.JS WAS NOT FOUND
    echo ============================================================
    echo.
    exit /b 1
)

call :capture_time TOTAL_START_MS
set "TOTAL_STARTED_AT=!DATE! !TIME!"

echo.
echo ############################################################
echo #                                                          #
echo # ANGULAR D3 OFFLINE PREPARATION                           #
echo #                                                          #
echo ############################################################
echo.
echo Process started:
echo   !TOTAL_STARTED_AT!
echo.
echo Source project:
echo   %SOURCE_ROOT%
echo.
echo Preparation directory:
echo   %PREP_ROOT%
echo.
echo Staging project:
echo   %STAGING_PROJECT%
echo.
echo Source npm cache:
echo   %ONLINE_CACHE%
echo.
echo Prepared offline cache:
echo   %OFFLINE_CACHE%
echo.
echo Final archive:
echo   %ARCHIVE%
echo.
echo Verification flow:
echo.
echo   [1/3] Online npm ci + build
echo   [2/3] Offline npm ci + build
echo   [3/3] Offline npm install + build
echo.
echo IMPORTANT:
echo   The following directory will be completely removed:
echo.
echo   %PREP_ROOT%
echo.

rem ============================================================
rem PREPARATION PHASE
rem ============================================================

call :capture_time PREPARATION_START_MS
set "PREPARATION_STARTED_AT=!DATE! !TIME!"

echo.
echo ############################################################
echo #                                                          #
echo # PREPARATION PHASE                                        #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !PREPARATION_STARTED_AT!
echo.
echo Operations:
echo.
echo   P.1 Verify tools and project files
echo   P.2 Clean C:\DEVEL\OFFLINE-PREP
echo   P.3 Record environment information
echo   P.4 Copy project into staging
echo   P.5 Copy npm cache
echo.

rem ============================================================
rem PREPARATION P.1
rem Verify required tools and files
rem ============================================================

echo.
echo ============================================================
echo PREPARATION P.1: VERIFYING PREREQUISITES
echo ============================================================
echo Started: !DATE! !TIME!
echo.

echo Checking Node.js...

where node >nul 2>&1

if errorlevel 1 (
    echo [FAILED] Node.js was not found.
    exit /b 1
)

echo [FOUND] Node.js
node --version

echo.
echo Checking npm...

where npm >nul 2>&1

if errorlevel 1 (
    echo [FAILED] npm was not found.
    exit /b 1
)

echo [FOUND] npm
call npm --version

echo.
echo Checking tar.exe...

where tar >nul 2>&1

if errorlevel 1 (
    echo [FAILED] tar.exe was not found.
    exit /b 1
)

echo [FOUND] tar.exe

echo.
echo Checking certutil.exe...

where certutil >nul 2>&1

if errorlevel 1 (
    echo [FAILED] certutil.exe was not found.
    exit /b 1
)

echo [FOUND] certutil.exe

echo.
echo Checking project files...

if not exist "%SOURCE_ROOT%\package.json" (
    echo [FAILED] Root package.json was not found:
    echo   %SOURCE_ROOT%\package.json
    exit /b 1
)

echo [FOUND] Root package.json

if not exist "%SOURCE_ROOT%\package-lock.json" (
    echo [FAILED] package-lock.json was not found:
    echo   %SOURCE_ROOT%\package-lock.json
    exit /b 1
)

echo [FOUND] package-lock.json

if not exist "%SOURCE_ROOT%\package\package.json" (
    echo [FAILED] Web Components package.json was not found:
    echo   %SOURCE_ROOT%\package\package.json
    exit /b 1
)

echo [FOUND] Web Components package.json

if not exist "%SOURCE_ROOT%\angular-app\package.json" (
    echo [FAILED] Angular application package.json was not found:
    echo   %SOURCE_ROOT%\angular-app\package.json
    exit /b 1
)

echo [FOUND] Angular application package.json

if not exist "%ONLINE_CACHE%" (
    echo [FAILED] Source npm cache was not found:
    echo   %ONLINE_CACHE%
    exit /b 1
)

echo [FOUND] Source npm cache

echo.
echo [COMPLETED] Preparation P.1
echo Completed: !DATE! !TIME!

rem ============================================================
rem PREPARATION P.2
rem Explicitly clean the preparation directory
rem ============================================================

echo.
echo ============================================================
echo PREPARATION P.2: CLEANING PREPARATION DIRECTORY
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Directory:
echo   %PREP_ROOT%
echo.
echo This removes all previous:
echo.
echo   - staging project files
echo   - copied npm cache files
echo   - temporary archive files
echo   - completed archives
echo   - checksum files
echo.

if exist "%PREP_ROOT%" (
    echo Removing the existing preparation directory...

    rmdir /S /Q "%PREP_ROOT%"

    if exist "%PREP_ROOT%" (
        echo.
        echo [FAILED] Could not remove the preparation directory:
        echo   %PREP_ROOT%
        exit /b 1
    )

    echo Existing preparation directory removed.
) else (
    echo Preparation directory does not currently exist.
)

echo.
echo Creating a clean preparation directory...

mkdir "%PREP_ROOT%"

if errorlevel 1 (
    echo [FAILED] Could not create:
    echo   %PREP_ROOT%
    exit /b 1
)

mkdir "%STAGING_PROJECT%"

if errorlevel 1 (
    echo [FAILED] Could not create:
    echo   %STAGING_PROJECT%
    exit /b 1
)

mkdir "%OFFLINE_CACHE%"

if errorlevel 1 (
    echo [FAILED] Could not create:
    echo   %OFFLINE_CACHE%
    exit /b 1
)

echo.
echo Clean preparation structure created:
echo.
echo   %PREP_ROOT%
echo   %STAGING_PROJECT%
echo   %OFFLINE_CACHE%
echo.
echo [COMPLETED] Preparation P.2
echo Completed: !DATE! !TIME!

rem ============================================================
rem PREPARATION P.3
rem Record environment information
rem ============================================================

echo.
echo ============================================================
echo PREPARATION P.3: RECORDING ENVIRONMENT
echo ============================================================
echo Started: !DATE! !TIME!
echo.

set "ENVIRONMENT_FILE=%SOURCE_ROOT%\OFFLINE-ENVIRONMENT.txt"

> "%ENVIRONMENT_FILE%" echo Angular D3 Offline Environment
>> "%ENVIRONMENT_FILE%" echo Prepared: %DATE% %TIME%
>> "%ENVIRONMENT_FILE%" echo.
>> "%ENVIRONMENT_FILE%" echo Node:

node --version >> "%ENVIRONMENT_FILE%" 2>&1

>> "%ENVIRONMENT_FILE%" echo.
>> "%ENVIRONMENT_FILE%" echo npm:

call npm --version >> "%ENVIRONMENT_FILE%" 2>&1

>> "%ENVIRONMENT_FILE%" echo.
>> "%ENVIRONMENT_FILE%" echo npm cache:

call npm config get cache >> "%ENVIRONMENT_FILE%" 2>&1

>> "%ENVIRONMENT_FILE%" echo.
>> "%ENVIRONMENT_FILE%" echo npm prefix:

call npm config get prefix >> "%ENVIRONMENT_FILE%" 2>&1

>> "%ENVIRONMENT_FILE%" echo.
>> "%ENVIRONMENT_FILE%" echo npm registry:

call npm config get registry >> "%ENVIRONMENT_FILE%" 2>&1

if not exist "%ENVIRONMENT_FILE%" (
    echo [FAILED] Environment report was not created.
    exit /b 1
)

echo Environment report created:
echo   %ENVIRONMENT_FILE%
echo.
echo [COMPLETED] Preparation P.3
echo Completed: !DATE! !TIME!

rem ============================================================
rem PREPARATION P.4
rem Copy project into staging
rem ============================================================

echo.
echo ============================================================
echo PREPARATION P.4: COPYING PROJECT INTO STAGING
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Source:
echo   %SOURCE_ROOT%
echo.
echo Destination:
echo   %STAGING_PROJECT%
echo.
echo Excluded directories:
echo.
echo   node_modules
echo   dist
echo   .angular
echo   .git
echo   .offline
echo.
echo Detailed Robocopy output is suppressed.
echo.

robocopy ^
  "%SOURCE_ROOT%" ^
  "%STAGING_PROJECT%" ^
  /MIR ^
  /XD ^
    node_modules ^
    dist ^
    .angular ^
    .git ^
    .offline ^
  /XF ^
    *.log ^
    angularD3-offline.tar.gz ^
    angularD3-offline.tar.gz.partial ^
    angularD3-offline.tar.gz.sha256.txt ^
  /NFL ^
  /NDL ^
  /NJH ^
  /NJS ^
  /NP ^
  /NC ^
  /NS ^
  >nul

set "ROBOCOPY_RESULT=!ERRORLEVEL!"

if !ROBOCOPY_RESULT! GEQ 8 (
    echo.
    echo [FAILED] Project copy failed.
    echo Robocopy exit code: !ROBOCOPY_RESULT!
    exit /b 1
)

if not exist "%STAGING_PROJECT%\package.json" (
    echo.
    echo [FAILED] Staging project was not copied correctly.
    echo Missing:
    echo   %STAGING_PROJECT%\package.json
    exit /b 1
)

echo Project copied successfully.
echo.
echo [COMPLETED] Preparation P.4
echo Completed: !DATE! !TIME!

rem ============================================================
rem PREPARATION P.5
rem Copy npm cache
rem ============================================================

echo.
echo ============================================================
echo PREPARATION P.5: COPYING NPM CACHE
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Source:
echo   %ONLINE_CACHE%
echo.
echo Destination:
echo   %OFFLINE_CACHE%
echo.
echo Detailed Robocopy output is suppressed.
echo.

robocopy ^
  "%ONLINE_CACHE%" ^
  "%OFFLINE_CACHE%" ^
  /E ^
  /NFL ^
  /NDL ^
  /NJH ^
  /NJS ^
  /NP ^
  /NC ^
  /NS ^
  >nul

set "CACHE_COPY_RESULT=!ERRORLEVEL!"

if !CACHE_COPY_RESULT! GEQ 8 (
    echo.
    echo [FAILED] npm cache copy failed.
    echo Robocopy exit code: !CACHE_COPY_RESULT!
    exit /b 1
)

echo npm cache copied successfully.
echo.
echo [COMPLETED] Preparation P.5
echo Completed: !DATE! !TIME!

cd /d "%STAGING_PROJECT%"

if errorlevel 1 (
    echo [FAILED] Could not enter:
    echo   %STAGING_PROJECT%
    exit /b 1
)

set "NODE_ENV="

call :capture_duration "!PREPARATION_START_MS!" PREPARATION_DURATION

echo.
echo ############################################################
echo #                                                          #
echo # PREPARATION PHASE COMPLETED                              #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !PREPARATION_STARTED_AT!
echo.
echo Completed:
echo   !DATE! !TIME!
echo.
echo Duration:
echo   !PREPARATION_DURATION!
echo.

rem ============================================================
rem STAGE 1 OF 3
rem Online npm ci + build
rem ============================================================

call :capture_time STAGE1_START_MS
set "STAGE1_STARTED_AT=!DATE! !TIME!"

echo.
echo.
echo ############################################################
echo #                                                          #
echo # STAGE 1 OF 3: ONLINE NPM CI AND BUILD                    #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !STAGE1_STARTED_AT!
echo.
echo Purpose:
echo.
echo   Populate and validate the prepared npm cache using an
echo   online clean installation, then build the complete project.
echo.
echo Operations:
echo.
echo   1.1 Online npm ci
echo   1.2 Verify Web Components dependency tree
echo   1.3 Build Web Components and Angular application
echo   1.4 Verify generated build outputs
echo.

rem ============================================================
rem STAGE 1.1
rem ============================================================

echo.
echo ============================================================
echo STAGE 1.1: ONLINE NPM CI
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Command:
echo.
echo   npm ci --prefer-online
echo.
echo Cache:
echo.
echo   %OFFLINE_CACHE%
echo.

call npm ci ^
  --cache "%OFFLINE_CACHE%" ^
  --prefer-online ^
  --no-audit ^
  --fund=false

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 1.1: ONLINE NPM CI
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 1.1
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 1.2
rem ============================================================

echo.
echo ============================================================
echo STAGE 1.2: VERIFYING WEB COMPONENTS DEPENDENCY TREE
echo ============================================================
echo Started: !DATE! !TIME!
echo.

call npm ls ^
  --workspace @angular-d3/web-components ^
  --depth=0

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 1.2: DEPENDENCY TREE IS INVALID
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 1.2
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 1.3
rem ============================================================

echo.
echo ============================================================
echo STAGE 1.3: ONLINE BUILD
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Command:
echo.
echo   npm run build
echo.

call npm run build

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 1.3: ONLINE BUILD
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 1.3
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 1.4
rem ============================================================

echo.
echo ============================================================
echo STAGE 1.4: VERIFYING ONLINE BUILD OUTPUTS
echo ============================================================
echo Started: !DATE! !TIME!
echo.

call :verify_build_outputs

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 1.4: BUILD OUTPUT VERIFICATION
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 1.4
echo Completed: !DATE! !TIME!

call :capture_duration "!STAGE1_START_MS!" STAGE1_DURATION

echo.
echo ############################################################
echo #                                                          #
echo # STAGE 1 OF 3 COMPLETED SUCCESSFULLY                      #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !STAGE1_STARTED_AT!
echo.
echo Completed:
echo   !DATE! !TIME!
echo.
echo Stage 1 duration:
echo   !STAGE1_DURATION!
echo.

rem ============================================================
rem CACHE READINESS PHASE
rem ============================================================

call :capture_time CACHE_START_MS
set "CACHE_STARTED_AT=!DATE! !TIME!"

echo.
echo.
echo ############################################################
echo #                                                          #
echo # CACHE READINESS VERIFICATION                             #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !CACHE_STARTED_AT!
echo.
echo Operations:
echo.
echo   C.1 Verify npm cache integrity
echo   C.2 Confirm SheetJS tarball cache entry
echo.

rem ============================================================
rem CACHE C.1
rem ============================================================

echo.
echo ============================================================
echo CACHE C.1: VERIFYING NPM CACHE INTEGRITY
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Cache:
echo.
echo   %OFFLINE_CACHE%
echo.

call npm cache verify ^
  --cache "%OFFLINE_CACHE%"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] CACHE C.1: NPM CACHE VERIFICATION
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Cache C.1
echo Completed: !DATE! !TIME!

rem ============================================================
rem CACHE C.2
rem ============================================================

echo.
echo ============================================================
echo CACHE C.2: VERIFYING SHEETJS TARBALL
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Expected cache entry:
echo.
echo   https://cdn.sheetjs.com/xlsx-0.20.2/xlsx-0.20.2.tgz
echo.

call npm cache ls ^
  --cache "%OFFLINE_CACHE%" ^
  | findstr /I /C:"cdn.sheetjs.com/xlsx-0.20.2/xlsx-0.20.2.tgz" >nul

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] CACHE C.2: SHEETJS TARBALL NOT FOUND
    echo ============================================================
    exit /b 1
)

echo [PASSED] Cache C.2
echo Completed: !DATE! !TIME!

call :capture_duration "!CACHE_START_MS!" CACHE_DURATION

echo.
echo ############################################################
echo #                                                          #
echo # CACHE READINESS VERIFICATION COMPLETED                   #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !CACHE_STARTED_AT!
echo.
echo Completed:
echo   !DATE! !TIME!
echo.
echo Cache verification duration:
echo   !CACHE_DURATION!
echo.

rem ============================================================
rem STAGE 2 OF 3
rem Offline npm ci + build
rem ============================================================

call :capture_time STAGE2_START_MS
set "STAGE2_STARTED_AT=!DATE! !TIME!"

echo.
echo.
echo ############################################################
echo #                                                          #
echo # STAGE 2 OF 3: OFFLINE NPM CI AND BUILD                   #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !STAGE2_STARTED_AT!
echo.
echo Purpose:
echo.
echo   Prove that a strict clean installation can be completed
echo   using only the prepared offline npm cache.
echo.
echo Operations:
echo.
echo   2.1 Remove Stage 1 node_modules
echo   2.2 Strict offline npm ci
echo   2.3 Build after offline npm ci
echo   2.4 Verify generated build outputs
echo.

rem ============================================================
rem STAGE 2.1
rem ============================================================

echo.
echo ============================================================
echo STAGE 2.1: REMOVING STAGE 1 NODE_MODULES
echo ============================================================
echo Started: !DATE! !TIME!
echo.

call :remove_node_modules

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 2.1: COULD NOT REMOVE NODE_MODULES
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 2.1
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 2.2
rem ============================================================

echo.
echo ============================================================
echo STAGE 2.2: STRICT OFFLINE NPM CI
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Command:
echo.
echo   npm ci --offline
echo.
echo Offline cache:
echo.
echo   %OFFLINE_CACHE%
echo.

call npm ci ^
  --offline ^
  --cache "%OFFLINE_CACHE%" ^
  --no-audit ^
  --fund=false

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 2.2: OFFLINE NPM CI
    echo ============================================================
    echo The prepared npm cache is incomplete or incompatible.
    exit /b 1
)

echo.
echo [PASSED] Stage 2.2
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 2.3
rem ============================================================

echo.
echo ============================================================
echo STAGE 2.3: BUILD AFTER OFFLINE NPM CI
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Command:
echo.
echo   npm run build
echo.

call npm run build

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 2.3: BUILD AFTER OFFLINE NPM CI
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 2.3
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 2.4
rem ============================================================

echo.
echo ============================================================
echo STAGE 2.4: VERIFYING OFFLINE NPM CI BUILD OUTPUTS
echo ============================================================
echo Started: !DATE! !TIME!
echo.

call :verify_build_outputs

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 2.4: BUILD OUTPUT VERIFICATION
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 2.4
echo Completed: !DATE! !TIME!

call :capture_duration "!STAGE2_START_MS!" STAGE2_DURATION

echo.
echo ############################################################
echo #                                                          #
echo # STAGE 2 OF 3 COMPLETED SUCCESSFULLY                      #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !STAGE2_STARTED_AT!
echo.
echo Completed:
echo   !DATE! !TIME!
echo.
echo Stage 2 duration:
echo   !STAGE2_DURATION!
echo.

rem ============================================================
rem STAGE 3 OF 3
rem Offline npm install + build
rem ============================================================

call :capture_time STAGE3_START_MS
set "STAGE3_STARTED_AT=!DATE! !TIME!"

echo.
echo.
echo ############################################################
echo #                                                          #
echo # STAGE 3 OF 3: OFFLINE NPM INSTALL AND BUILD              #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !STAGE3_STARTED_AT!
echo.
echo Purpose:
echo.
echo   Verify the normal offline npm install workflow and confirm
echo   that package-lock.json remains unchanged.
echo.
echo Operations:
echo.
echo   3.1 Remove Stage 2 node_modules
echo   3.2 Back up package-lock.json
echo   3.3 Normal offline npm install
echo   3.4 Compare package-lock.json
echo   3.5 Build after offline npm install
echo   3.6 Verify generated build outputs
echo.

rem ============================================================
rem STAGE 3.1
rem ============================================================

echo.
echo ============================================================
echo STAGE 3.1: REMOVING STAGE 2 NODE_MODULES
echo ============================================================
echo Started: !DATE! !TIME!
echo.

call :remove_node_modules

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 3.1: COULD NOT REMOVE NODE_MODULES
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 3.1
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 3.2
rem ============================================================

echo.
echo ============================================================
echo STAGE 3.2: BACKING UP PACKAGE-LOCK.JSON
echo ============================================================
echo Started: !DATE! !TIME!
echo.

copy /Y ^
  package-lock.json ^
  package-lock.before-offline-test.json ^
  >nul

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 3.2: LOCKFILE BACKUP
    echo ============================================================
    exit /b 1
)

echo Lockfile backup created:
echo   %STAGING_PROJECT%\package-lock.before-offline-test.json
echo.
echo [PASSED] Stage 3.2
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 3.3
rem ============================================================

echo.
echo ============================================================
echo STAGE 3.3: NORMAL OFFLINE NPM INSTALL
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Command:
echo.
echo   npm install --offline
echo.
echo Offline cache:
echo.
echo   %OFFLINE_CACHE%
echo.

call npm install ^
  --offline ^
  --cache "%OFFLINE_CACHE%" ^
  --no-audit ^
  --fund=false

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 3.3: OFFLINE NPM INSTALL
    echo ============================================================

    del /Q ^
      package-lock.before-offline-test.json ^
      >nul 2>&1

    exit /b 1
)

echo.
echo [PASSED] Stage 3.3
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 3.4
rem ============================================================

echo.
echo ============================================================
echo STAGE 3.4: VERIFYING PACKAGE-LOCK.JSON
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Comparing package-lock.json with its pre-install backup...
echo.

fc /B ^
  package-lock.before-offline-test.json ^
  package-lock.json ^
  >nul

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 3.4: PACKAGE-LOCK.JSON CHANGED
    echo ============================================================
    echo.
    echo The offline npm install modified package-lock.json.
    echo Review dependency declarations or npm version differences.

    del /Q ^
      package-lock.before-offline-test.json ^
      >nul 2>&1

    exit /b 1
)

del /Q ^
  package-lock.before-offline-test.json ^
  >nul 2>&1

echo [PASSED] Stage 3.4
echo package-lock.json remained unchanged.
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 3.5
rem ============================================================

echo.
echo ============================================================
echo STAGE 3.5: BUILD AFTER OFFLINE NPM INSTALL
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Command:
echo.
echo   npm run build
echo.

call npm run build

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 3.5: BUILD AFTER OFFLINE NPM INSTALL
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 3.5
echo Completed: !DATE! !TIME!

rem ============================================================
rem STAGE 3.6
rem ============================================================

echo.
echo ============================================================
echo STAGE 3.6: VERIFYING OFFLINE NPM INSTALL BUILD OUTPUTS
echo ============================================================
echo Started: !DATE! !TIME!
echo.

call :verify_build_outputs

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] STAGE 3.6: BUILD OUTPUT VERIFICATION
    echo ============================================================
    exit /b 1
)

echo.
echo [PASSED] Stage 3.6
echo Completed: !DATE! !TIME!

call :capture_duration "!STAGE3_START_MS!" STAGE3_DURATION

echo.
echo ############################################################
echo #                                                          #
echo # STAGE 3 OF 3 COMPLETED SUCCESSFULLY                      #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !STAGE3_STARTED_AT!
echo.
echo Completed:
echo   !DATE! !TIME!
echo.
echo Stage 3 duration:
echo   !STAGE3_DURATION!
echo.

rem ============================================================
rem FINALIZATION PHASE
rem ============================================================

call :capture_time FINALIZATION_START_MS
set "FINALIZATION_STARTED_AT=!DATE! !TIME!"

echo.
echo.
echo ############################################################
echo #                                                          #
echo # FINALIZATION: CREATING OFFLINE TRANSFER PACKAGE          #
echo #                                                          #
echo ############################################################
echo.
echo Started:
echo   !FINALIZATION_STARTED_AT!
echo.
echo All three installation and build stages passed.
echo.
echo Finalization operations:
echo.
echo   F.1 Save exact dependency tree
echo   F.2 Generate advisory code-quality report
echo   F.3 Remove node_modules
echo   F.4 Create installation instructions
echo   F.5 Create compressed .tar.gz archive
echo   F.6 Generate SHA-256 checksum
echo.

rem ============================================================
rem FINALIZATION F.1
rem ============================================================

echo.
echo ============================================================
echo FINALIZATION F.1: SAVING EXACT DEPENDENCY TREE
echo ============================================================
echo Started: !DATE! !TIME!
echo.

call npm ls ^
  --all ^
  --workspaces ^
  > "%STAGING_PROJECT%\OFFLINE-DEPENDENCIES.txt" 2>&1

echo Dependency report created:
echo   %STAGING_PROJECT%\OFFLINE-DEPENDENCIES.txt
echo.
echo [COMPLETED] Finalization F.1
echo Completed: !DATE! !TIME!

rem ============================================================
rem FINALIZATION F.2
rem ============================================================

echo.
echo ============================================================
echo FINALIZATION F.2: GENERATING CODE-QUALITY REPORT
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Prettier and ESLint findings are advisory.
echo They will not stop offline preparation.
echo.

call :verify_code_quality

echo.
echo [COMPLETED] Finalization F.2
echo Completed: !DATE! !TIME!

rem ============================================================
rem FINALIZATION F.3
rem ============================================================

echo.
echo ============================================================
echo FINALIZATION F.3: REMOVING NODE_MODULES
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Generated dist directories will be retained.
echo Only installed node_modules directories will be removed.
echo.

call :remove_node_modules

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] FINALIZATION F.3: NODE_MODULES REMOVAL
    echo ============================================================
    exit /b 1
)

echo.
echo [COMPLETED] Finalization F.3
echo Completed: !DATE! !TIME!

rem ============================================================
rem FINALIZATION F.4
rem ============================================================

echo.
echo ============================================================
echo FINALIZATION F.4: CREATING INSTALLATION INSTRUCTIONS
echo ============================================================
echo Started: !DATE! !TIME!
echo.

(
    echo Angular D3 Offline Installation
    echo ===============================
    echo.
    echo 1. Install the exact Node/npm versions from OFFLINE-ENVIRONMENT.txt.
    echo 2. Copy the npm-cache directory to C:\npm-offline-cache.
    echo 3. Run configure-offline-npm.cmd.
    echo 4. Run npm install.
    echo 5. Run npm run lint.
    echo 6. Optionally run npm run format:check.
    echo 7. Run npm run build.
    echo 8. Run npm run dev.
    echo.
    echo Stop development mode with q followed by Enter or Ctrl+C.
) > "%STAGING_PROJECT%\OFFLINE-INSTALLATION.txt"

if not exist "%STAGING_PROJECT%\OFFLINE-INSTALLATION.txt" (
    echo [FAILED] Installation instructions were not created.
    exit /b 1
)

echo Installation instructions created:
echo   %STAGING_PROJECT%\OFFLINE-INSTALLATION.txt
echo.
echo [COMPLETED] Finalization F.4
echo Completed: !DATE! !TIME!

rem ============================================================
rem FINALIZATION F.5
rem ============================================================

echo.
echo ============================================================
echo FINALIZATION F.5: CREATING COMPRESSED ARCHIVE
echo ============================================================
echo Started: !DATE! !TIME!
echo.
echo Final archive:
echo   %ARCHIVE%
echo.
echo Temporary archive:
echo   %ARCHIVE_TEMP%
echo.
echo Included directories:
echo.
echo   %STAGING_PROJECT%
echo   %OFFLINE_CACHE%
echo.
echo Archive compression is running.
echo tar may remain silent until compression finishes.
echo.

if exist "%ARCHIVE%" (
    del /Q "%ARCHIVE%"
)

if exist "%ARCHIVE_TEMP%" (
    del /Q "%ARCHIVE_TEMP%"
)

if exist "%CHECKSUM_FILE%" (
    del /Q "%CHECKSUM_FILE%"
)

cd /d "%PREP_ROOT%"

if errorlevel 1 (
    echo [FAILED] Could not enter:
    echo   %PREP_ROOT%
    exit /b 1
)

tar -czf ^
  "%ARCHIVE_TEMP%" ^
  angularD3 ^
  npm-cache

set "TAR_RESULT=!ERRORLEVEL!"

if not "!TAR_RESULT!"=="0" (
    echo.
    echo ============================================================
    echo [FAILED] FINALIZATION F.5: ARCHIVE CREATION
    echo ============================================================
    echo tar exit code: !TAR_RESULT!

    if exist "%ARCHIVE_TEMP%" (
        del /Q "%ARCHIVE_TEMP%"
    )

    exit /b 1
)

if not exist "%ARCHIVE_TEMP%" (
    echo.
    echo ============================================================
    echo [FAILED] FINALIZATION F.5: TEMPORARY ARCHIVE MISSING
    echo ============================================================
    echo Expected:
    echo   %ARCHIVE_TEMP%
    exit /b 1
)

move /Y "%ARCHIVE_TEMP%" "%ARCHIVE%" >nul

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] FINALIZATION F.5: ARCHIVE FINALIZATION
    echo ============================================================
    exit /b 1
)

if not exist "%ARCHIVE%" (
    echo.
    echo ============================================================
    echo [FAILED] FINALIZATION F.5: FINAL ARCHIVE MISSING
    echo ============================================================
    exit /b 1
)

echo Archive created successfully:
echo   %ARCHIVE%
echo.
echo [COMPLETED] Finalization F.5
echo Completed: !DATE! !TIME!

rem ============================================================
rem FINALIZATION F.6
rem ============================================================

echo.
echo ============================================================
echo FINALIZATION F.6: GENERATING SHA-256 CHECKSUM
echo ============================================================
echo Started: !DATE! !TIME!
echo.

certutil ^
  -hashfile "%ARCHIVE%" SHA256 ^
  > "%CHECKSUM_FILE%"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [FAILED] FINALIZATION F.6: CHECKSUM GENERATION
    echo ============================================================
    exit /b 1
)

if not exist "%CHECKSUM_FILE%" (
    echo.
    echo ============================================================
    echo [FAILED] FINALIZATION F.6: CHECKSUM FILE MISSING
    echo ============================================================
    exit /b 1
)

echo Checksum created successfully:
echo   %CHECKSUM_FILE%
echo.
echo [COMPLETED] Finalization F.6
echo Completed: !DATE! !TIME!

call :capture_duration "!FINALIZATION_START_MS!" FINALIZATION_DURATION
call :capture_duration "!TOTAL_START_MS!" TOTAL_DURATION

rem ============================================================
rem SUCCESS SUMMARY
rem ============================================================

echo.
echo.
echo ############################################################
echo #                                                          #
echo # OFFLINE PREPARATION COMPLETED SUCCESSFULLY               #
echo #                                                          #
echo ############################################################
echo.
echo Process started:
echo   !TOTAL_STARTED_AT!
echo.
echo Process completed:
echo   !DATE! !TIME!
echo.
echo Total process duration:
echo   !TOTAL_DURATION!
echo.
echo Phase durations:
echo.
echo   Preparation phase:       !PREPARATION_DURATION!
echo   Stage 1 - Online ci:     !STAGE1_DURATION!
echo   Cache verification:      !CACHE_DURATION!
echo   Stage 2 - Offline ci:    !STAGE2_DURATION!
echo   Stage 3 - Offline install: !STAGE3_DURATION!
echo   Finalization:            !FINALIZATION_DURATION!
echo.
echo Completed verification stages:
echo.
echo   [PASSED] Stage 1 - Online npm ci and build
echo   [PASSED] Stage 2 - Offline npm ci and build
echo   [PASSED] Stage 3 - Offline npm install and build
echo.
echo Cache verification:
echo.
echo   [PASSED] npm cache integrity
echo   [PASSED] SheetJS xlsx-0.20.2 tarball
echo.
echo Build outputs:
echo.
echo   [PASSED] ESM Web Components bundle
echo   [PASSED] UMD Web Components bundle
echo   [PASSED] Global stylesheet dist\css\index.css
echo   [PASSED] TinyMCE runtime assets
echo.
echo Final files:
echo.
echo   [CREATED] %STAGING_PROJECT%\OFFLINE-ENVIRONMENT.txt
echo   [CREATED] %STAGING_PROJECT%\OFFLINE-DEPENDENCIES.txt
echo   [CREATED] %STAGING_PROJECT%\OFFLINE-CODE-QUALITY.txt
echo   [CREATED] %STAGING_PROJECT%\OFFLINE-INSTALLATION.txt
echo   [CREATED] %ARCHIVE%
echo   [CREATED] %CHECKSUM_FILE%
echo.
echo Transfer directory:
echo.
echo   %PREP_ROOT%
echo.

goto :eof

rem ============================================================
rem SUBROUTINES
rem ============================================================

:capture_time
for /f "delims=" %%T in ('node -p "Date.now()"') do (
    set "%~1=%%T"
)

exit /b 0


:capture_duration
for /f "delims=" %%D in ('
    node -e "const start=Number(process.argv[1]);const elapsed=Math.max(0,Date.now()-start);const totalSeconds=Math.floor(elapsed/1000);const hours=Math.floor(totalSeconds/3600);const minutes=Math.floor((totalSeconds%%3600)/60);const seconds=totalSeconds%%60;process.stdout.write(String(hours).padStart(2,'0')+':'+String(minutes).padStart(2,'0')+':'+String(seconds).padStart(2,'0'));" "%~1"
') do (
    set "%~2=%%D"
)

exit /b 0


:remove_node_modules
echo Removing installed dependencies...

if exist "%STAGING_PROJECT%\node_modules" (
    echo   Removing root node_modules...

    rmdir /S /Q "%STAGING_PROJECT%\node_modules"

    if exist "%STAGING_PROJECT%\node_modules" (
        echo [FAILED] Could not remove root node_modules.
        exit /b 1
    )
) else (
    echo   Root node_modules does not exist.
)

if exist "%STAGING_PROJECT%\package\node_modules" (
    echo   Removing Web Components node_modules...

    rmdir /S /Q "%STAGING_PROJECT%\package\node_modules"

    if exist "%STAGING_PROJECT%\package\node_modules" (
        echo [FAILED] Could not remove Web Components node_modules.
        exit /b 1
    )
) else (
    echo   Web Components node_modules does not exist.
)

if exist "%STAGING_PROJECT%\angular-app\node_modules" (
    echo   Removing Angular node_modules...

    rmdir /S /Q "%STAGING_PROJECT%\angular-app\node_modules"

    if exist "%STAGING_PROJECT%\angular-app\node_modules" (
        echo [FAILED] Could not remove Angular node_modules.
        exit /b 1
    )
) else (
    echo   Angular node_modules does not exist.
)

echo Installed dependencies removed.

exit /b 0


:verify_code_quality
set "QUALITY_LOG=%STAGING_PROJECT%\OFFLINE-CODE-QUALITY.txt"

echo Checking code quality...
echo Detailed output:
echo   %QUALITY_LOG%
echo.

> "%QUALITY_LOG%" echo Angular D3 Code Quality Report
>> "%QUALITY_LOG%" echo Generated: %DATE% %TIME%
>> "%QUALITY_LOG%" echo.
>> "%QUALITY_LOG%" echo ============================================================
>> "%QUALITY_LOG%" echo Prettier
>> "%QUALITY_LOG%" echo ============================================================

call npm run format:check >> "%QUALITY_LOG%" 2>&1
set "FORMAT_RESULT=!ERRORLEVEL!"

>> "%QUALITY_LOG%" echo.
>> "%QUALITY_LOG%" echo Prettier exit code: !FORMAT_RESULT!
>> "%QUALITY_LOG%" echo.
>> "%QUALITY_LOG%" echo ============================================================
>> "%QUALITY_LOG%" echo ESLint
>> "%QUALITY_LOG%" echo ============================================================

call npm run lint >> "%QUALITY_LOG%" 2>&1
set "LINT_RESULT=!ERRORLEVEL!"

>> "%QUALITY_LOG%" echo.
>> "%QUALITY_LOG%" echo ESLint exit code: !LINT_RESULT!

if "!FORMAT_RESULT!"=="0" (
    echo [PASSED] Prettier formatting check.
) else (
    echo [WARNING] Prettier found formatting differences.
)

if "!LINT_RESULT!"=="0" (
    echo [PASSED] ESLint verification.
) else (
    echo [WARNING] ESLint found code-quality issues.
)

echo Formatting and lint findings are advisory.
echo Offline preparation will continue.

exit /b 0


:verify_build_outputs
if not exist "%STAGING_PROJECT%\package\dist\angular-d3-components.esm.js" (
    echo [FAILED] ESM Web Components bundle was not created.
    echo Expected:
    echo   %STAGING_PROJECT%\package\dist\angular-d3-components.esm.js
    exit /b 1
)

echo [FOUND] ESM Web Components bundle

if not exist "%STAGING_PROJECT%\package\dist\angular-d3-components.umd.js" (
    echo [FAILED] UMD Web Components bundle was not created.
    echo Expected:
    echo   %STAGING_PROJECT%\package\dist\angular-d3-components.umd.js
    exit /b 1
)

echo [FOUND] UMD Web Components bundle

if not exist "%STAGING_PROJECT%\package\dist\css\index.css" (
    echo [FAILED] Global Web Components stylesheet was not created.
    echo Expected:
    echo   %STAGING_PROJECT%\package\dist\css\index.css
    echo.
    echo Stylesheets found under package\dist:

    dir /S /B "%STAGING_PROJECT%\package\dist\*.css" 2>nul

    exit /b 1
)

echo [FOUND] Global stylesheet dist\css\index.css

if not exist "%STAGING_PROJECT%\package\dist\tinymce\tinymce.min.js" (
    echo [FAILED] TinyMCE runtime assets were not copied.
    echo Expected:
    echo   %STAGING_PROJECT%\package\dist\tinymce\tinymce.min.js
    exit /b 1
)

echo [FOUND] TinyMCE runtime assets
echo Build outputs verified.

exit /b 0