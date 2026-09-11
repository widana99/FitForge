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

:: 2. Masukkan username Docker Hub (default otomatis: ginoputrawidana)
set DOCKERHUB_USER=ginoputrawidana
set /p USER_INPUT="Masukkan Username Docker Hub [%DOCKERHUB_USER%]: "
if not "!USER_INPUT!"=="" set DOCKERHUB_USER=!USER_INPUT!

echo.
echo [1/4] Login ke Docker Hub sebagai '!DOCKERHUB_USER!'...
echo (Jika diminta password, PASTE Personal Access Token Anda, lalu tekan Enter):
docker login -u !DOCKERHUB_USER!
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Login gagal. Pastikan username dan Personal Access Token benar.
    pause
    exit /b 1
)

echo.
echo [2/4] Membangun (Build) Docker Images FitForge Web & Admin...
docker compose -f docker-compose.lab.yml build
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build image gagal. Periksa pesan error di atas.
    pause
    exit /b 1
)

echo.
echo [3/4] Melakukan Tagging image untuk !DOCKERHUB_USER!...
docker tag fitforge-web:latest !DOCKERHUB_USER!/fitforge-web:latest
docker tag fitforge-admin:latest !DOCKERHUB_USER!/fitforge-admin:latest

echo.
echo [4/4] Mengunggah (Push) ke Docker Hub (harap tunggu proses upload)...
docker push !DOCKERHUB_USER!/fitforge-web:latest
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Gagal push fitforge-web ke Docker Hub.
    pause
    exit /b 1
)

docker push !DOCKERHUB_USER!/fitforge-admin:latest
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Gagal push fitforge-admin ke Docker Hub.
    pause
    exit /b 1
)

echo.
echo ========================================================
echo   [SUKSES] Image Berhasil Diunggah ke Docker Hub!
echo ========================================================
echo Image Anda telah tersedia di cloud Docker Hub:
echo   - https://hub.docker.com/r/!DOCKERHUB_USER!/fitforge-web
echo   - https://hub.docker.com/r/!DOCKERHUB_USER!/fitforge-admin
echo.
echo Cara Menjalankan di Komputer Lab (PLAN B):
echo   set DOCKERHUB_USER=!DOCKERHUB_USER!
echo   docker compose -f docker-compose.hub.yml up -d
echo ========================================================
echo.
pause
