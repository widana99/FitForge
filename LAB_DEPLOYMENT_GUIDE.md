# Panduan Lengkap Instalasi & Deployment Docker FitForge di Komputer Lab Kampus

Panduan ini disusun secara terperinci agar aplikasi **FitForge** (Flutter Mobile/Web) dan **FitForge Admin** (Next.js 16) dapat dijalankan di komputer lab kampus **100% lancar dan bebas error**, tanpa memerlukan instalasi manual Flutter SDK, Android Studio, Java, atau Node.js di komputer lab, serta **tidak bergantung pada koneksi internet kampus** yang sering lambat atau diblokir firewall.

---

## Daftar Isi
1. [Arsitektur & Konsep Bebas Error](#1-arsitektur--konsep-bebas-error)
2. [Langkah 1: Persiapan di Laptop Sendiri (Export ke Flashdisk)](#2-langkah-1-persiapan-di-laptop-sendiri-export-ke-flashdisk)
3. [Langkah 2: Menjalankan di Komputer Lab Kampus (1-Klik)](#3-langkah-2-menjalankan-di-komputer-lab-kampus-1-klik)
4. [Alternatif Tanpa Flashdisk (Google Drive, GitHub, Docker Hub)](#4-alternatif-tanpa-flashdisk-google-drive-github-docker-hub)
5. [Langkah 3: Pengujian Aplikasi (Web & Smartphone Fisik)](#5-langkah-3-pengujian-aplikasi-web--smartphone-fisik)
6. [Langkah 4: Pembersihan Setelah Demo/Presentasi Selesai](#6-langkah-4-pembersihan-setelah-demopresentasi-selesai)
7. [Troubleshooting Panduan Solusi Semua Error Khas Komputer Lab](#7-troubleshooting-panduan-solusi-semua-error-khas-komputer-lab)

---

## 1. Arsitektur & Konsep Bebas Error

Kenapa instalasi manual di komputer lab kampus sering gagal?
* Komputer lab tidak memiliki SDK Flutter, Node.js versi 20+, atau Android SDK.
* Akun komputer lab biasanya berstatus *User Terbatas* (bukan Administrator penuh).
* Virtualisasi Android Emulator di lab sering dinonaktifkan di BIOS (*VT-x disabled*).
* Koneksi internet lab kampus lambat / memblokir download dependensi NPM & Gradle.

**Solusi FitForge:**
1. **FitForge Flutter (Port 8080):** Dikonversi menjadi Flutter Web release di dalam container **Nginx Alpine** (~25MB). Berjalan langsung di browser komputer lab dengan tampilan responsif, tanpa emulator Android yang berat.
2. **FitForge Admin (Port 3000):** Dibangun dengan **Next.js Standalone Mode** di container `node:20-alpine` (~130MB, bukan 1GB+).
3. **Android APK (`app-release.apk`):** Disediakan langsung di dalam folder flashdisk agar dosen/asisten lab dapat menguji langsung di smartphone fisik.
4. **Offline Tarball USB:** Kedua Docker image diekspor ke satu berkas `fitforge-images.tar`. Di komputer lab, Anda cukup menjalankan `docker load` dari Flashdisk (tidak butuh kuota/internet lab sama sekali!).

---

## 2. Langkah 1: Persiapan di Laptop Sendiri (Export ke Flashdisk)

Lakukan langkah ini di laptop Anda yang memiliki koneksi internet stabil sebelum berangkat ke kampus:

### A. Pastikan Docker Desktop Terinstal & Berjalan di Laptop Anda
Jika laptop Anda belum memiliki Docker Desktop:
1. Download installer resmi: [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/).
2. Install dengan mencentang opsi **Use WSL 2 instead of Hyper-V (recommended)**.
3. Restart laptop, buka Docker Desktop, dan tunggu hingga ikon paus di taskbar pojok kanan bawah berwarna hijau/putih stabil (*Engine running*).

### B. Jalankan Skrip Ekspor Otomatis
1. Buka folder proyek FitForge di laptop Anda:
   ```cmd
   cd c:\Users\Lenovo\.gemini\antigravity\scratch\fitforge
   ```
2. Klik dua kali file:
   ```cmd
   export-lab-bundle.bat
   ```
   *(Atau jalankan `./export-lab-bundle.sh` jika menggunakan macOS / Linux).*

3. Skrip otomatis akan:
   * Mem-build image Flutter Web (`fitforge-web:latest`).
   * Mem-build image Next.js Admin (`fitforge-admin:latest`).
   * Mengekstrak file APK Android ke folder `dist-lab\apk\app-release.apk`.
   * Mengekspor seluruh image ke arsip offline `dist-lab\fitforge-images.tar`.
   * Menyiapkan file `docker-compose.yml`, `run-in-lab.bat`, dan `stop-in-lab.bat`.

### C. Salin Folder `dist-lab` ke Flashdisk USB
Setelah skrip selesai, akan muncul folder bernama **`dist-lab`**.
* Salin (**Copy**) seluruh folder **`dist-lab`** tersebut ke dalam USB Flashdisk Anda (kapasitas yang disarankan minimal 4 GB).

Isi folder `dist-lab` di flashdisk Anda akan berupa:
```text
dist-lab/
├── apk/
│   └── app-release.apk        <-- File APK untuk smartphone Android
├── docker-compose.yml         <-- Konfigurasi orkestrasi container
├── fitforge-images.tar        <-- Arsip Docker image offline (~500MB - 1GB)
├── .env                       <-- Konfigurasi port (8080 & 3000)
├── run-in-lab.bat             <-- Skrip 1-Klik Jalankan di Lab (Windows)
├── run-in-lab.sh              <-- Skrip 1-Klik Jalankan di Lab (Linux/Mac)
├── stop-in-lab.bat            <-- Skrip Matikan Container
└── stop-in-lab.sh
```

---

## 3. Langkah 2: Menjalankan di Komputer Lab Kampus (1-Klik)

Saat Anda berada di lab komputer kampus:

1. **Colokkan USB Flashdisk** ke komputer lab.
2. Buka aplikasi **Docker Desktop** yang ada di komputer lab (bisa dicari dari menu Windows Start). Pastikan Docker Desktop sudah menyala (*Engine running*).
3. Buka folder `dist-lab` yang ada di Flashdisk Anda.
4. **Klik dua kali file:**
   ```text
   run-in-lab.bat
   ```
5. Tunggu proses berlangsung (biasanya hanya 10 - 20 detik):
   * Skrip akan me-*load* image `fitforge-images.tar` dari flashdisk secara offline.
   * Skrip menjalankan `docker compose up -d`.
   * Skrip otomatis membuka browser komputer lab ke kedua URL aplikasi!

---

## 4. Alternatif Tanpa Flashdisk (Google Drive, GitHub, Docker Hub)

Jika kampus Anda **melarang penggunaan Flashdisk USB** (misalnya port USB dikunci oleh admin lab demi keamanan dan pencegahan virus), gunakan salah satu dari 3 cara legal dan aman berikut:

### Opsi A: Menggunakan Cloud Storage Kampus (Google Drive / OneDrive) - *Paling Mudah*
1. Di laptop Anda, jalankan `export-lab-bundle.bat` seperti biasa hingga folder `dist-lab` terbentuk.
2. Kompres/Zip folder `dist-lab` menjadi file `dist-lab.zip`.
3. Upload `dist-lab.zip` ke akun **Google Drive** atau **OneDrive** kampus Anda.
4. Di komputer lab:
   - Buka browser lab, login ke Google Drive / OneDrive Anda.
   - Download `dist-lab.zip` ke folder `Downloads` atau `Desktop` komputer lab.
   - Klik kanan -> *Extract All* (Ekstrak Semua).
   - Masuk ke folder hasil ekstrak, lalu klik dua kali **`run-in-lab.bat`**.
   *(Semua image tetap di-load secara lokal dari file tarball tanpa butuh internet saat proses Docker berjalan).*

---

### Opsi B: Menggunakan Docker Hub / Container Registry - *Standar Industri DevOps*
Anda dapat mengunggah image ke Docker Hub (gratis) dari laptop Anda, sehingga di lab komputer hanya perlu menarik (*pull*) image tersebut:
1. Di laptop Anda, beri tag pada image dan upload ke Docker Hub:
   ```cmd
   docker tag fitforge-web:latest <username-dockerhub>/fitforge-web:latest
   docker tag fitforge-admin:latest <username-dockerhub>/fitforge-admin:latest
   docker push <username-dockerhub>/fitforge-web:latest
   docker push <username-dockerhub>/fitforge-admin:latest
   ```
2. Di komputer lab:
   - Anda hanya butuh satu file `docker-compose.yml` (bisa diketik / disalin dari pesan WA Web, GitHub Gist, atau email).
   - Ubah baris `image:` menjadi `<username-dockerhub>/fitforge-web:latest` dan `<username-dockerhub>/fitforge-admin:latest`.
   - Jalankan terminal lab: `docker compose up -d`.
   - Docker akan langsung mendownload image yang sudah jadi via koneksi HTTPS resmi Docker Hub (yang umumnya diizinkan oleh jaringan kampus).

---

### Opsi C: Menggunakan Git Repository (GitHub / GitLab)
Jika komputer lab mengizinkan `git`:
1. Push kedua proyek ke repositori GitHub Anda:
   ```bash
   git push origin feature/docker-lab-deployment
   ```
2. Di komputer lab, buka Command Prompt / PowerShell:
   ```cmd
   git clone <URL_REPO_GITHUB_ANDA>
   cd fitforge
   docker compose -f docker-compose.lab.yml up --build -d
   ```
   Docker di komputer lab akan otomatis mem-build seluruh source code dan menjalankan kedua container.

---

### Opsi D: Tampilkan Langsung dari Laptop via Hotspot / Local IP (Tanpa Sentuh Komputer Lab)
Jika Anda membawa laptop ke lab dan komputer lab terhubung ke jaringan Wi-Fi yang sama (atau tersambung ke Hotspot HP Anda):
1. Di laptop Anda, jalankan container: `docker compose -f docker-compose.lab.yml up -d`.
2. Cek IP lokal laptop Anda di Command Prompt: `ipconfig` (misalnya: `192.168.1.50`).
3. Di browser komputer lab kampus, Anda dan dosen cukup membuka:
   - FitForge User Web: `http://192.168.1.50:8080`
   - FitForge Admin Dashboard: `http://192.168.1.50:3000`
   *(Cara ini 100% aman, tidak perlu install atau memindahkan file apapun ke komputer lab).*

---

## 5. Langkah 3: Pengujian Aplikasi (Web & Smartphone Fisik)

Setelah skrip berjalan, kedua aplikasi dapat diakses secara langsung:

| Layanan | URL Browser | Keterangan |
|---|---|---|
| **FitForge User App** | `http://localhost:8080` | Aplikasi Flutter versi Web responsif (bisa dibuka dengan F12 mobile view). |
| **FitForge Admin Dashboard** | `http://localhost:3000` | Dashboard admin Next.js 16 lengkap dengan manajemen latihan & workout. |

### Jika Dosen Ingin Menguji di Smartphone Fisik:
1. Di flashdisk, buka folder `dist-lab\apk\`.
2. Kirim file `app-release.apk` ke smartphone (via WhatsApp Web, Google Drive, atau kabel USB).
3. Install APK di smartphone Android (aktifkan *Install from Unknown Sources* jika diminta).
4. Aplikasi FitForge versi Android native siap dicoba langsung.

---

## 5. Langkah 4: Pembersihan Setelah Demo/Presentasi Selesai

Agar komputer lab kampus tetap bersih dan tidak meninggalkan proses yang memakan memori:
1. Di folder Flashdisk `dist-lab`, klik dua kali file:
   ```text
   stop-in-lab.bat
   ```
2. Container akan otomatis dimatikan dan dihapus secara bersih (`docker compose down`).
3. Anda dapat mencabut Flashdisk dengan aman (*Safely Remove Hardware*).

---

## 6. Troubleshooting Panduan Solusi Semua Error Khas Komputer Lab

Berikut panduan langkah demi langkah jika menemukan kendala di komputer lab:

### Kendala 1: `Docker tidak terdeteksi atau belum berjalan`
* **Penyebab:** Docker Desktop belum dibuka atau servicenya masih proses *starting*.
* **Solusi:**
  1. Buka aplikasi **Docker Desktop** dari desktop atau Start Menu.
  2. Perhatikan ikon paus di taskbar (kanan bawah dekat jam). Jika warnanya masih kuning/berputar (*Starting*), tunggu 1-2 menit sampai berwarna putih/hijau stabil (*Engine running*).
  3. Setelah itu, jalankan kembali `run-in-lab.bat`.

### Kendala 2: `Virtualization is not enabled in the BIOS` / Error VT-x AMD-V
* **Penyebab:** BIOS komputer lab mematikan fitur virtualisasi CPU.
* **Solusi:**
  * Komputer lab kampus biasanya sudah disiapkan oleh teknisi lab untuk praktikum. Jika muncul pesan ini:
    1. Laporkan ke asisten lab / teknisi lab: *"Mohon izin mengaktifkan fitur Intel Virtualization Technology (VT-x) atau AMD-V di menu BIOS"*.
    2. Atau gunakan mode **Hyper-V** jika komputer lab menggunakan Windows Enterprise/Pro tanpa WSL 2.

### Kendala 3: `WSL 2 installation is incomplete`
* **Penyebab:** Paket update kernel WSL 2 Microsoft belum terpasang di Windows lab.
* **Solusi:**
  * Bawa file installer kernel WSL 2 di Flashdisk Anda: download terlebih dahulu di rumah dari tautan resmi Microsoft:
    `https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi`
  * Di lab, klik dua kali file `wsl_update_x64.msi` untuk menginstall, lalu restart Docker Desktop.

### Kendala 4: `Port 8080 or 3000 is already in use` (Konflik Port)
* **Penyebab:** Komputer lab sudah memiliki aplikasi lain yang berjalan di port 8080 (seperti Apache/Tomcat/XAMPP) atau port 3000.
* **Solusi:**
  1. Di folder `dist-lab`, buka file `.env` menggunakan Notepad.
  2. Ubah nomor port, misalnya:
     ```env
     FITFORGE_WEB_PORT=8085
     FITFORGE_ADMIN_PORT=3005
     ```
  3. Simpan file `.env`.
  4. Jalankan kembali `run-in-lab.bat`. Sekarang aplikasi akan berjalan di `http://localhost:8085` dan `http://localhost:3005`.

### Kendala 5: `Windows Defender Firewall blocked some features`
* **Penyebab:** Windows Firewall lab meminta konfirmasi akses jaringan untuk Docker/Nginx.
* **Solusi:**
  * Centang pilihan **Private networks** dan klik tombol **Allow access**. (Ini aman karena aplikasi hanya berjalan di `localhost`).

### Kendala 6: Navigasi Flutter Web Error 404 saat di-refresh
* **Status:** **SUDAH TERATASI OTOMATIS** oleh konfigurasi `nginx.conf` FitForge. File `nginx.conf` sudah menyertakan `try_files $uri $uri/ /index.html;` sehingga URL routing tetap mulus meskipun halaman di-*refresh*.
