@echo off
setlocal
where mvn >nul 2>nul
if %ERRORLEVEL% equ 0 (
    mvn %*
) else if exist "C:\Users\Nithy\.maven\maven-3.9.16\bin\mvn.cmd" (
    "C:\Users\Nithy\.maven\maven-3.9.16\bin\mvn.cmd" %*
) else (
    echo [ERROR] Maven not found. Please install Maven or add it to PATH.
    exit /b 1
)
