@echo off
echo ========================================================
echo   FitForge - PLAN C: Build Langsung dari Source Git
echo ========================================================
echo.

docker compose -f docker-compose.lab.yml up --build -d
if %errorlevel% neq 0 (
    echo [ERROR] Build dari source gagal. Periksa koneksi internet lab atau log error.
    pause
    exit /b 1
)

echo.
echo [OK] Container berhasil di-build dan berjalan!
echo Membuka browser dalam 5 detik...
timeout /t 5 /nobreak >nul
start http://localhost:8080
start http://localhost:3000
pause
