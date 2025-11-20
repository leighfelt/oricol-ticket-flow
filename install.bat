@echo off
REM Oricol Ticket Flow - Windows Installer (Batch)
REM This script clones the GitHub repository and sets up the application

setlocal enabledelayedexpansion

REM Configuration
set GITHUB_REPO=https://github.com/craigfelt/oricol-ticket-flow-c5475242.git
set INSTALL_DIR=lpc

REM Display banner
echo.
echo ============================================================
echo.
echo        Oricol Ticket Flow - Auto Installer
echo.
echo ============================================================
echo.

echo [INFO] Starting installation process...
echo.

REM Check if Git is installed
echo [INFO] Checking for Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed!
    echo.
    echo Please install Git from: https://git-scm.com/download/win
    echo After installation, restart this script.
    pause
    exit /b 1
)
echo [SUCCESS] Git is installed
echo.

REM Check if Node.js is installed
echo [INFO] Checking for Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed!
    echo.
    echo Please install Node.js from: https://nodejs.org/
    echo After installation, restart this script.
    pause
    exit /b 1
)
echo [SUCCESS] Node.js is installed
echo.

REM Check if npm is installed
echo [INFO] Checking for npm...
npm --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm is not installed!
    echo.
    echo npm should come with Node.js. Please reinstall Node.js.
    pause
    exit /b 1
)
echo [SUCCESS] npm is installed
echo.

REM Get current directory
set CURRENT_DIR=%cd%
echo [INFO] Installation directory: %CURRENT_DIR%\%INSTALL_DIR%
echo.

REM Check if installation directory already exists
if exist "%INSTALL_DIR%" (
    echo [WARNING] Directory '%INSTALL_DIR%' already exists!
    set /p RESPONSE="Do you want to remove it and reinstall? (y/N): "
    if /i "!RESPONSE!"=="y" (
        echo [INFO] Removing existing directory...
        rmdir /s /q "%INSTALL_DIR%"
        echo [SUCCESS] Existing directory removed
        echo.
    ) else (
        echo [INFO] Installation cancelled by user
        pause
        exit /b 0
    )
)

REM Clone the repository
echo [INFO] Cloning repository from GitHub...
git clone %GITHUB_REPO% %INSTALL_DIR%
if errorlevel 1 (
    echo [ERROR] Failed to clone repository!
    pause
    exit /b 1
)
echo [SUCCESS] Repository cloned successfully
echo.

REM Change to installation directory
cd %INSTALL_DIR%

REM Install dependencies
echo [INFO] Installing npm dependencies...
echo [INFO] This may take a few minutes...
call npm install
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies!
    cd %CURRENT_DIR%
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies installed successfully
echo.

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo [INFO] Creating .env file from template...
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo [SUCCESS] .env file created
        echo [WARNING] IMPORTANT: Edit the .env file with your Supabase credentials!
        echo.
    ) else (
        echo [WARNING] .env.example not found. You'll need to create .env manually.
        echo.
    )
)

REM Return to original directory
cd %CURRENT_DIR%

REM Display completion message
echo.
echo ============================================================
echo.
echo        Installation Complete!
echo.
echo ============================================================
echo.
echo [SUCCESS] Oricol Ticket Flow has been installed to: %CURRENT_DIR%\%INSTALL_DIR%
echo.
echo Next Steps:
echo   1. Edit the .env file with your Supabase credentials:
echo      cd %INSTALL_DIR%
echo      notepad .env
echo.
echo   2. Run database migrations:
echo      cd %INSTALL_DIR%
echo      npm run migrate
echo.
echo   3. Start the development server:
echo      npm run dev
echo.
echo   4. Open your browser to: http://localhost:8080
echo.
echo For more information, see README.md in the %INSTALL_DIR% directory
echo.
pause
