@echo off
setlocal EnableExtensions

set "PROJECT_ROOT=C:\DEVEL\angularDev\OrgAtlas"
set "REPOSITORY_URL=https://github.com/marcusAvreli/OrgAtlas.git"
set "BRANCH=master"

cd /d "%PROJECT_ROOT%" || (
    echo ERROR: Unable to access %PROJECT_ROOT%
    exit /b 1
)

echo ============================================================
echo Initializing OrgAtlas Git repository
echo ============================================================
echo.

if not exist ".git" (
    git init || exit /b 1
) else (
    echo Git repository is already initialized.
)

rem ============================================================
rem Create the root .gitignore.
rem Patterns without a leading slash apply at every directory level.
rem ============================================================

(
    echo # ========================================================
    echo # Dependencies
    echo # ========================================================
    echo node_modules/
    echo.
    echo # ========================================================
    echo # Build output
    echo # ========================================================
    echo dist/
    echo build/
    echo out-tsc/
    echo coverage/
    echo.
    echo # ========================================================
    echo # Angular generated files
    echo # ========================================================
    echo .angular/
    echo.
    echo # ========================================================
    echo # Caches and temporary files
    echo # ========================================================
    echo .cache/
    echo .sass-cache/
    echo .tmp/
    echo tmp/
    echo temp/
    echo *.tmp
    echo *.temp
    echo.
    echo # ========================================================
    echo # Logs
    echo # ========================================================
    echo *.log
    echo npm-debug.log*
    echo yarn-debug.log*
    echo yarn-error.log*
    echo pnpm-debug.log*
    echo.
    echo # ========================================================
    echo # IDE files
    echo # ========================================================
    echo .vscode/
    echo .idea/
    echo .settings/
    echo .project
    echo .classpath
    echo *.code-workspace
    echo.
    echo # ========================================================
    echo # Operating-system files
    echo # ========================================================
    echo .DS_Store
    echo Thumbs.db
    echo Desktop.ini
    echo.
    echo # ========================================================
    echo # Local environment and secret files
    echo # ========================================================
    echo .env
    echo .env.*
    echo !.env.example
    echo *.local
    echo *.key
    echo *.pem
    echo *.pfx
    echo *.p12
    echo *.jks
    echo *.keystore
    echo.
    echo # ========================================================
    echo # Generated documentation
    echo # Remove these entries if documentation must be committed.
    echo # ========================================================
    echo docs/
    echo package/docs/
) > ".gitignore"

echo Created root .gitignore.
echo.

rem ============================================================
rem Configure the remote.
rem ============================================================

git remote get-url origin >nul 2>&1

if errorlevel 1 (
    git remote add origin "%REPOSITORY_URL%" || exit /b 1
    echo Added remote origin.
) else (
    git remote set-url origin "%REPOSITORY_URL%" || exit /b 1
    echo Updated remote origin.
)

rem ============================================================
rem Remove previously tracked files from the Git index.
rem Files remain unchanged on disk.
rem This is safe when migrating an existing repository.
rem ============================================================

git rm -r --cached . >nul 2>&1

rem Re-add files while respecting .gitignore.
git add .

echo.
echo Files prepared for commit:
echo ------------------------------------------------------------
git status --short
echo ------------------------------------------------------------
echo.

git diff --cached --quiet

if not errorlevel 1 (
    echo No files are available to commit.
    exit /b 0
)

git commit -m "initial_commit" || exit /b 1
git branch -M "%BRANCH%" || exit /b 1
git push -u origin "%BRANCH%" || exit /b 1

echo.
echo ============================================================
echo OrgAtlas repository initialized successfully
echo ============================================================

endlocal