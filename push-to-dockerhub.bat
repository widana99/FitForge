@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   FitForge - PLAN B: Push Docker Images ke Docker Hub
echo ========================================================
echo.

:: 1. Cek status Docker
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker tidak terdeteksi atau Docker Desktop belum berjalan.
    pause
    exit /b 1
)

:: 2. Masukkan username Docker Hub
set /p DOCKERHUB_USER="Masukkan Username Docker Hub Anda: "
if "%DOCKERHUB_USER%"=="" (
    echo [ERROR] Username tidak boleh kosong!
    pause
    exit /b 1
)

echo.
echo [1/4] Login ke Docker Hub...
docker login
if %errorlevel% neq 0 (
    echo [ERROR] Login gagal. Pastikan username dan password/token benar.
    pause
    exit /b 1
)

echo.
echo [2/4] Memastikan image lokal sudah ter-build...
docker compose -f docker-compose.lab.yml build

echo.
echo [3/4] Melakukan Tagging image...
docker tag fitforge-web:latest %DOCKERHUB_USER%/fitforge-web:latest
docker tag fitforge-admin:latest %DOCKERHUB_USER%/fitforge-admin:latest

echo.
echo [4/4] Mengunggah (Push) ke Docker Hub...
docker push %DOCKERHUB_USER%/fitforge-web:latest
docker push %DOCKERHUB_USER%/fitforge-admin:latest

echo.
echo ========================================================
echo   [SUKSES] Image Berhasil Diunggah ke Docker Hub!
echo ========================================================
echo Image Anda:
echo   - %DOCKERHUB_USER%/fitforge-web:latest
echo   - %DOCKERHUB_USER%/fitforge-admin:latest
echo.
echo Cara Menjalankan di Komputer Lab (PLAN B):
echo   1. Di komputer lab, buat file 'docker-compose.yml' atau buka terminal.
echo   2. Set variabel lingkungan lalu jalankan:
echo        set DOCKERHUB_USER=%DOCKERHUB_USER%
echo        docker compose -f docker-compose.hub.yml up -d
echo ========================================================
echo.
pause
