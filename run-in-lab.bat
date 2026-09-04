@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   FitForge - Campus Lab 1-Click Runner
echo ========================================================
echo.

:: 1. Verify Docker Daemon
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker tidak terdeteksi atau belum berjalan di komputer lab ini!
    echo.
    echo Solusi:
    echo   1. Buka aplikasi 'Docker Desktop' dari Start Menu / Desktop lab.
    echo   2. Tunggu hingga ikon paus Docker di taskbar berwarna hijau/putih stabil ('Engine running').
    echo   3. Jalankan kembali file 'run-in-lab.bat' ini.
    echo.
    pause
    exit /b 1
)

:: 2. Load Offline Images if tarball exists
if exist "fitforge-images.tar" (
    echo [1/3] Mendeteksi arsip offline 'fitforge-images.tar'...
    echo Memuat image Docker dari Flashdisk ke komputer lab...
    docker load -i fitforge-images.tar
    if %errorlevel% neq 0 (
        echo [WARNING] Gagal memuat file tarball. Mencoba menjalankan container yang sudah ada...
    ) else (
        echo [OK] Docker images berhasil dimuat tanpa perlu koneksi internet!
    )
) else (
    echo [1/3] File 'fitforge-images.tar' tidak ditemukan di folder ini.
    echo Menggunakan image lokal atau pull online jika tersedia...
)

:: 3. Start Containers
echo.
echo [2/3] Menjalankan service FitForge Web & Admin...
docker compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Gagal menjalankan container.
    echo Jika ada konflik port (8080 atau 3000 sedang dipakai),
    echo silakan edit file '.env' dan ubah nomor portnya.
    pause
    exit /b 1
)

:: 4. Waiting and Launching Browser
echo.
echo [3/3] Menunggu inisialisasi service (5 detik)...
timeout /t 5 /nobreak >nul

echo.
echo ========================================================
echo   [SUKSES] Aplikasi FitForge Berhasil Berjalan di Lab!
echo ========================================================
echo   1. FitForge User App (Flutter Web) : http://localhost:8080
echo   2. FitForge Admin Dashboard        : http://localhost:3000
echo ========================================================
echo.
echo Membuka aplikasi di browser...
start http://localhost:8080
start http://localhost:3000

echo.
echo Catatan: Untuk menghentikan aplikasi dan membersihkan container setelah selesai,
echo klik dua kali file 'stop-in-lab.bat'.
echo.
pause
