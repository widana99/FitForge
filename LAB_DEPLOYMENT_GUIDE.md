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

---

## 4. Alternatif Tanpa Flashdisk: Strategi 3 Lapis (Plan A, Plan B, Plan C)

Jika kampus Anda **melarang penggunaan Flashdisk USB** (karena port USB dinonaktifkan oleh administrator lab demi keamanan), kami telah menyiapkan **3 Lapis Rencana (Multi-Tier Plan)** agar presentasi Anda 100% aman dan tidak gagal:

```
[PLAN A: Google Drive ZIP Bundle]  <-- UTAMA (Paling cepat, offline runtime)
         │ (jika Google Drive diblokir/gagal)
         ▼
[PLAN B: Docker Hub Image Pull]    <-- CADANGAN 1 (Tarik image via HTTPS resmi)
         │ (jika Docker Hub lambat/dibatasi)
         ▼
[PLAN C: Git Clone & Auto-Build]   <-- CADANGAN 2 (Build langsung dari source di lab)
         │ (jika internet lab down total)
         ▼
[PLAN D: Direct Hotspot / Local IP]<-- CADANGAN DARURAT (Laptop -> Browser Lab)
```

---

### 🟢 PLAN A (Utama): Google Drive / OneDrive ZIP Bundle
*Metode ini direkomendasikan karena paling cepat dan tidak memerlukan download dependensi saat proses Docker berjalan di lab.*

1. **Di Laptop Anda:**
   - Jalankan file `export-lab-bundle.bat`.
   - Skrip sekarang **otomatis membuat file `dist-lab.zip`** di folder proyek Anda.
   - Buka Google Drive / OneDrive akun kampus Anda via browser di laptop, lalu unggah file `dist-lab.zip`.
2. **Di Komputer Lab Kampus:**
   - Buka browser lab $\rightarrow$ login ke Google Drive / OneDrive Anda.
   - Download file `dist-lab.zip` ke folder `Downloads` atau `Desktop`.
   - Klik kanan file `dist-lab.zip` $\rightarrow$ pilih **Extract All** (Ekstrak Semua).
   - Buka folder hasil ekstrak, lalu klik dua kali:
     ```text
     run-in-lab.bat
     ```
   - *Selesai!* Aplikasi langsung terbuka di browser lab tanpa memakan kuota internet lab.

---

### 🟡 PLAN B (Cadangan 1): Docker Hub Image Pull
*Gunakan ini jika Google Drive diblokir atau komputer lab tidak mengizinkan download file .zip.*

1. **Di Laptop Anda (Sebelum ke Kampus):**
   - Pastikan Anda memiliki akun gratis di [hub.docker.com](https://hub.docker.com/).
   - Klik dua kali skrip:
     ```text
     push-to-dockerhub.bat
     ```
   - Masukkan username Docker Hub Anda dan password/token saat diminta. Skrip akan otomatis mengunggah kedua image:
     - `<username>/fitforge-web:latest`
     - `<username>/fitforge-admin:latest`
2. **Di Komputer Lab Kampus:**
   - Buka Command Prompt / PowerShell di komputer lab, buat folder baru:
     ```cmd
     mkdir C:\fitforge-demo
     cd C:\fitforge-demo
     ```
   - Buat file `docker-compose.yml` (bisa di-copy dari email / WA Web / Notepad):
     ```yaml
     services:
       fitforge-web:
         image: <username>/fitforge-web:latest
         ports:
           - "8080:80"
       fitforge-admin:
         image: <username>/fitforge-admin:latest
         ports:
           - "3000:3000"
     ```
   - Jalankan perintah:
     ```cmd
     docker compose up -d
     ```
   - Buka browser lab ke `http://localhost:8080` dan `http://localhost:3000`.

---

### 🟠 PLAN C (Cadangan 2): Git Clone & Build Langsung di Lab
*Gunakan ini jika image registry diblokir, namun akses GitHub/Git diizinkan di lab.*

1. **Di Laptop Anda:**
   - Pastikan branch proyek sudah dipush ke GitHub:
     ```bash
     git push origin feature/docker-lab-deployment
     ```
2. **Di Komputer Lab Kampus:**
   - Buka Command Prompt di lab:
     ```cmd
     git clone <URL_REPO_GITHUB_ANDA>
     cd fitforge
     build-from-git.bat
     ```
   - Skrip `build-from-git.bat` akan mem-build kedua container dari source code dan otomatis membuka browser saat selesai.

---

### 🔴 PLAN D (Cadangan Darurat): Direct Hotspot / Local IP
*Gunakan ini jika komputer lab benar-benar terkunci (tidak bisa install apapun), namun Anda membawa laptop.*

1. Hubungkan laptop Anda dan komputer lab ke Wi-Fi yang sama (atau sambungkan komputer lab ke Hotspot HP Anda).
2. Di laptop Anda, jalankan container:
   ```cmd
   docker compose -f docker-compose.lab.yml up -d
   ```
3. Cek IP lokal laptop Anda di CMD laptop: `ipconfig` (misalnya muncul `192.168.1.45`).
4. Di browser komputer lab, buka:
   - **`http://192.168.1.45:8080`** (FitForge Web)
   - **`http://192.168.1.45:3000`** (FitForge Admin)
   *Aplikasi berjalan mulus di layar komputer lab tanpa menyentuh sistem lab sama sekali!*

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
