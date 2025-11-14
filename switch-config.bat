@echo off
REM Quick switch script for local vs lovable configurations
REM Usage: switch-config.bat local
REM        switch-config.bat lovable

if "%1"=="" (
    echo Usage: switch-config.bat [local^|lovable]
    echo.
    echo Examples:
    echo   switch-config.bat local    - Switch to local development config
    echo   switch-config.bat lovable  - Switch to lovable/cloud config
    exit /b 1
)

if /I "%1"=="local" (
    echo 🔄 Switching to LOCAL configuration...
    copy /Y .env.local .env
    echo ✅ Copied .env.local to .env
    echo.
    echo 📝 Next steps:
    echo   1. Start Docker services:
    echo      docker compose -f docker-compose.yml -f docker-compose.override.local.yml up -d
    echo.
    echo   2. Start dev server:
    echo      npm run dev
    echo.
    echo   3. Access at:
    echo      - Frontend: http://localhost:5173
    echo      - API: http://localhost:8001
    echo      - Studio: http://localhost:3001
) else if /I "%1"=="lovable" (
    echo 🔄 Switching to LOVABLE configuration...
    copy /Y .env.lovable .env
    echo ✅ Copied .env.lovable to .env
    echo.
    echo 📝 Next steps:
    echo   Option A - Use cloud Supabase (recommended for lovable):
    echo      npm run build ^&^& npm run preview
    echo.
    echo   Option B - Use self-hosted with Docker:
    echo      docker compose -f docker-compose.yml -f docker-compose.override.lovable.yml up -d
    echo      npm run build ^&^& npm run preview
) else (
    echo ❌ Invalid config: %1
    echo Usage: switch-config.bat [local^|lovable]
    exit /b 1
)

echo.
echo ✅ Configuration switched successfully!
