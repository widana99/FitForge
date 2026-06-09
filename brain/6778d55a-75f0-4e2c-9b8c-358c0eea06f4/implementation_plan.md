# Menambahkan Fitur "Kustomisasi Berbasis Tujuan (Goals)"

Dokumen ini membedah rancangan arsitektur untuk memisahkan logika **Tujuan (Goals)** dengan **Fokus Tubuh**, sekaligus memenuhi kebutuhan UX agar *user* tidak perlu masuk ke Pengaturan hanya untuk mengganti program hariannya.

## User Review Required

> [!IMPORTANT]
> Fitur ini sangat logis untuk ditambahkan, dan pengamatan Anda bahwa "pergi ke pengaturan untuk ganti program itu tidak efektif" adalah 100% akurat. 
> Untuk memastikannya tidak tumpang tindih dengan "Fokus Tubuh", apakah Anda setuju jika program *Fat Loss* nanti kita buat waktu istirahatnya sangat pendek (15 detik), sementara *Bangun Otot* istirahatnya lama (60 detik)? (Persetujuan ini penting sebelum saya menulis kodenya).

## Proposed Changes

---

### Home Screen & Routing

#### [MODIFY] [home_screen.dart](file:///c:/Users/Lenovo/.gemini/antigravity/scratch/fitforge/lib/screens/home/home_screen.dart)
Menambahkan seksi `_buildGoalSelectionSection()` persis di atas (atau di bawah) seksi `_buildFocusSection()`. Seksion ini akan berisi 3 kartu melintang yang elegan:
- 🔥 Turun Berat Badan (Menu: Fat Loss)
- 💪 Bangun Otot (Menu: Muscle Building)
- 🏃 Jaga Kebugaran (Menu: General Fitness)

#### [MODIFY] [app_routes.dart](file:///c:/Users/Lenovo/.gemini/antigravity/scratch/fitforge/lib/config/routes/app_routes.dart)
Mendaftarkan rute baru bernama `/goal_workout` untuk navigasi dari kartu tujuan.

#### [NEW] [goal_workout_screen.dart](file:///c:/Users/Lenovo/.gemini/antigravity/scratch/fitforge/lib/screens/home/goal_workout_screen.dart)
Sebuah layar baru yang secara visual mirip dengan `FocusWorkoutScreen` (agar konsisten). Memungkinkan *user* menekan kartu *Goals Selection*, lalu disambut dengan slider **Tingkat Kesulitan** dan **Ketersediaan Alat** khusus untuk target Tujuan mereka.

---

### Backend Logic Engine

#### [MODIFY] [workout_presets.dart](file:///c:/Users/Lenovo/.gemini/antigravity/scratch/fitforge/lib/services/workout_presets.dart)
Membuat fungsi algoritma baru secara independen yang bernama `getWorkoutsByGoal()` yang bukan hanya mencari filter otot, melainkan mengubah **Struktur Program (Sets / Reps / Rest):**
*   **Jika Turun BB (Fat Loss):** Memilih kategori kombinasi `Perut + Kaki + Kardio`. Rumus: *Sets* dipertahankan 3-4, *Reps* ditinggikan ke 20, dan Waktu Istirahat (`restTime`) dipaksa merosot ke kisaran **15-20 detik** saja (Sirkuit / HIIT).
*   **Jika Bangun Otot:** Memilih kategori `Lengan + Bokong/Dada`. Rumus: *Sets* dibuat tinggi 4-5, *Reps* ditekan di angka 8-12, dan Waktu Istirahat dipaksa melonggar ke **60 detik** (Fokus Hipertrofi & Tenaga).
*   **Jika Jaga Kebugaran:** Mencampur seluruh *database* secara acak, repetisi wajar 12-15, dan istirahat standar **30 detik**.

## Open Questions

> [!TIP]
> Jika saya sudah diizinkan, di mana posisi persis yang Anda inginkan untuk Kartu "Kategori Tujuan" ini di Beranda?
> A. Menjadi tombol "Pilih" langsung mengganti fungsi Rekomendasi Utama paling atas.
> B. Menjadi baris tersendiri (Horizontal Scroll) tepat di bawah Rekomendasi Utama.

## Verification Plan

### Manual Verification
1.  Menjalankan Emulator, menekan tombol *Fat Loss* dari Beranda.
2.  Mengecek apakah di halaman Latihan, waktu istirahatnya turun jadi pendek (15-20s).
3.  Memeriksa agar "Fokus Tubuh" (Dada/Perut) tetap tidak berubah jadwal istirahat klasiknya (30s).
