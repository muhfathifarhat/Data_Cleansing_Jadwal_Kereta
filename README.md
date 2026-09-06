# Data Cleansing: Jadwal Kereta Api

Project data cleansing menggunakan **SQL di Google BigQuery** untuk membersihkan dataset jadwal kereta api yang kotor menjadi dataset yang rapi dan siap dianalisis, sebagai bagian dari portofolio saya di bidang **Data Analysis**.

---

## Latar Belakang & Tujuan

Dataset mentah sering kali memiliki berbagai masalah kualitas data yang perlu dibersihkan sebelum bisa dianalisis. Untuk mengasah kemampuan data cleansing, saya membuat dataset dummy jadwal kereta api yang sengaja kotor menggunakan AI - Claude, lalu membersihkannya menggunakan SQL di BigQuery.

Tujuan project ini:
- Mengidentifikasi berbagai masalah kualitas data pada dataset mentah
- Menerapkan teknik data cleansing menggunakan SQL (standarisasi format, penanganan missing value, dll)
- Menghasilkan dataset bersih yang konsisten dan siap digunakan untuk analisis lanjutan

---

## Dataset yang Digunakan

- **Sumber:** Data dummy, di-generate menggunakan Claude AI
- **Isi data:** id_jadwal, nama_kereta, nomor_kereta, stasiun_asal, stasiun_tujuan, tanggal_berangkat, jam_berangkat, jam_tiba, kelas, harga_tiket, status
- **Jumlah baris:** ±3.000 baris

---

## Masalah Data yang Ditemukan (Dirty Data)

| Kolom | Masalah |
|---|---|
| `id_jadwal` | Inkonsistensi huruf besar/kecil (contoh: `jka01310` vs `JKA01310`) |
| `nama_kereta` | Ada spasi berlebih di awal/akhir teks, ada nilai kosong |
| `nomor_kereta` | Terdapat nilai yang kosong/hilang |
| `tanggal_berangkat` | Format tanggal tidak konsisten (`22-10-2024`, `2025-01-03`, `15 Jan 2025`, `24/02/2025`) |
| `jam_berangkat` & `jam_tiba` | Format jam tidak konsisten (`13.05`, `17:05`, `02:20:00`) |
| `kelas` | Inkonsistensi kapitalisasi dan spasi (`Bisnis `, `eksekutif`, ` Eksekutif`) |
| `harga_tiket` | Beberapa nilai memakai format teks (`Rp50.236`) alih-alih angka murni |
| `status` | Inkonsistensi kapitalisasi (`TERLAMBAT`, `Terlambat`, `tepat waktu`) dan nilai kosong/simbol (`-`) |

---

## Proses Cleansing yang Dilakukan

1. **Standarisasi teks** — menyeragamkan huruf besar/kecil pada `id_jadwal`, `kelas`, dan `status`
2. **Trimming** — menghapus spasi berlebih pada kolom teks seperti `nama_kereta` dan `kelas`
3. **Parsing tanggal & jam** — menyeragamkan berbagai format tanggal dan jam ke satu format standar (`YYYY-MM-DD` dan `HH:MM:SS`)
4. **Pembersihan nilai numerik** — menghapus karakter non-angka (`Rp`, titik ribuan) pada kolom `harga_tiket`
5. **Set tipe data** — Mengubah tipe data menjadi sesuai dengan isi data semestinya menggunakan `CAST`

---

<p align="center"><i>Terima kasih sudah mampir! :*</i></p>