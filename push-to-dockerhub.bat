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

:: 2. Username Docker Hub
set DOCKERHUB_USER=ginoputrawidana
set /p USER_INPUT="Masukkan Username Docker Hub [%DOCKERHUB_USER%]: "
if not "!USER_INPUT!"=="" set DOCKERHUB_USER=!USER_INPUT!

echo.
echo [1/4] Login ke Docker Hub sebagai '!DOCKERHUB_USER!'...
echo Anda bisa memasukkan PASSWORD AKUN Docker Hub Anda ATAU Personal Access Token.
echo.
set /p DOCKER_PASS="Password atau Access Token: "

if "!DOCKER_PASS!"=="" (
    echo.
    echo [ERROR] Password / Token tidak boleh kosong!
    pause
    exit /b 1
)

echo.
echo Sedang memverifikasi login ke Docker Hub...
set "ENV_PASS=!DOCKER_PASS!"
powershell -Command "$p = $env:ENV_PASS.Trim(); $p | docker login -u %DOCKERHUB_USER% --password-stdin"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Login gagal. Pastikan password atau token yang dimasukkan benar.
    pause
    exit /b 1
)

echo.
echo [2/4] Memeriksa Docker Images FitForge Web & Admin...
docker compose -f docker-compose.lab.yml build
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build image gagal.
    pause
    exit /b 1
)

echo.
echo [3/4] Melakukan Tagging image untuk !DOCKERHUB_USER!...
docker tag fitforge-web:latest !DOCKERHUB_USER!/fitforge-web:latest
docker tag fitforge-admin:latest !DOCKERHUB_USER!/fitforge-admin:latest

echo.
echo [4/4] Mengunggah (Push) ke Docker Hub...
echo Mengunggah fitforge-web:latest...
docker push !DOCKERHUB_USER!/fitforge-web:latest
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Gagal push fitforge-web ke Docker Hub.
    pause
    exit /b 1
)

echo Mengunggah fitforge-admin:latest...
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
