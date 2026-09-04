@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   FitForge - Export Docker Lab Bundle (Portable USB)
echo ========================================================
echo.

:: 1. Check Docker Daemon
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker tidak terdeteksi atau Docker Desktop belum berjalan.
    echo Pastikan Docker Desktop sudah dibuka dan berstatus 'Running'.
    pause
    exit /b 1
)

echo [1/5] Membuat direktori output dist-lab...
if not exist "dist-lab" mkdir dist-lab
if not exist "dist-lab\apk" mkdir dist-lab\apk

echo [2/5] Membangun Docker Image FitForge Web & FitForge Admin...
docker compose -f docker-compose.lab.yml build
if %errorlevel% neq 0 (
    echo [ERROR] Gagal mem-build Docker Image. Periksa log di atas.
    pause
    exit /b 1
)

echo [3/5] (Opsional) Mem-build APK Android ke dist-lab\apk...
echo Proses ini mengekstrak APK Release untuk pengujian langsung di smartphone lab...
docker build --target apk-exporter --output type=local,dest=dist-lab/apk . 2>nul
if exist "dist-lab\apk\app-release.apk" (
    echo [OK] APK berhasil diekstrak ke dist-lab\apk\app-release.apk
) else (
    echo [INFO] Build APK dilewati / memerlukan waktu tambahan. Web container tetap siap.
)

echo [4/5] Mengekspor Docker Images ke arsip tarball (fitforge-images.tar)...
echo Harap tunggu, proses ini memakan waktu 1-2 menit tergantung kecepatan SSD...
docker save fitforge-web:latest fitforge-admin:latest -o dist-lab\fitforge-images.tar
if %errorlevel% neq 0 (
    echo [ERROR] Gagal mengekspor docker images ke tarball.
    pause
    exit /b 1
)

echo [5/5] Menyalin script eksekusi lab ke folder dist-lab...
copy /Y run-in-lab.bat dist-lab\run-in-lab.bat >nul
copy /Y run-in-lab.sh dist-lab\run-in-lab.sh >nul
copy /Y stop-in-lab.bat dist-lab\stop-in-lab.bat >nul
copy /Y stop-in-lab.sh dist-lab\stop-in-lab.sh >nul
copy /Y .env.example dist-lab\.env >nul

:: Buat docker-compose khusus untuk lab yang langsung menggunakan image lokal
(
echo services:
echo   fitforge-web:
echo     image: fitforge-web:latest
echo     container_name: fitforge-web
echo     ports:
echo       - "$${FITFORGE_WEB_PORT:-8080}:80"
echo     restart: unless-stopped
echo     deploy:
echo       resources:
echo         limits:
echo           memory: 512M
echo     healthcheck:
echo       test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:80/"]
echo       interval: 30s
echo       timeout: 5s
echo       retries: 3
echo.
echo   fitforge-admin:
echo     image: fitforge-admin:latest
echo     container_name: fitforge-admin
echo     ports:
echo       - "$${FITFORGE_ADMIN_PORT:-3000}:3000"
echo     restart: unless-stopped
echo     deploy:
echo       resources:
echo         limits:
echo           memory: 512M
echo     healthcheck:
echo       test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/"]
echo       interval: 30s
echo       timeout: 5s
echo       retries: 3
) > dist-lab\docker-compose.yml

echo.
echo ========================================================
echo   [SUKSES] Lab Bundle Siap Digunakan!
echo ========================================================
echo Seluruh berkas siap dipindahkan ke Flashdisk ada di folder:
echo   %CD%\dist-lab\
echo.
echo Langkah selanjutnya:
echo   1. Copy folder 'dist-lab' ke USB Flashdisk Anda.
echo   2. Di komputer Lab Kampus, colok Flashdisk, buka folder 'dist-lab'.
echo   3. Klik dua kali 'run-in-lab.bat' (tanpa butuh download internet lab!).
echo ========================================================
echo.
pause
