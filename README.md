# Data Cleaning: Jadwal Keberangkatan Kereta Api (BigQuery SQL)

## 📌 Deskripsi Proyek
Proyek ini adalah latihan **data cleaning / data wrangling** menggunakan **Google BigQuery (SQL)**. Tujuannya adalah mengubah data mentah (raw/dirty) jadwal keberangkatan kereta api yang tidak konsisten menjadi dataset yang bersih, terstandardisasi, dan siap dianalisis.

## 📂 Dataset

| | Detail |
|---|---|
| Sumber | `jadwal_kereta_dirty` (data sintetis/dummy) |
| Jumlah baris (raw) | ±3.060 baris |
| Jumlah baris (setelah cleaning) | 3.000 baris |
| Jumlah kolom | 11 kolom |
| Tabel hasil | `jadwal_kereta_clean` |

**Kolom:** `id_jadwal`, `nama_kereta`, `nomor_kereta`, `stasiun_asal`, `stasiun_tujuan`, `tanggal_berangkat`, `jam_berangkat`, `jam_tiba`, `kelas`, `harga_tiket`, `status`

## 🧩 Masalah pada Data Mentah
Data mentah sengaja dibuat dengan masalah kualitas data yang umum ditemukan di dunia nyata:

- **Duplikasi baris** — beberapa baris identik muncul lebih dari sekali.
- **Format tanggal tidak konsisten** — campuran `YYYY-MM-DD`, `DD/MM/YYYY`, `DD-MM-YYYY`, dan `DD Mon YYYY`.
- **Format jam tidak konsisten** — campuran `HH:MM`, `HH:MM:SS`, dan `HH.MM`.
- **Whitespace & inkonsistensi kapitalisasi** — contoh: `"  Argo Bromo  "`, `"EKONOMI"`, `"eksekutif"`.
- **Variasi nilai null** — `NULL`, `N/A`, `null`, `-`, `NaN`, kosong (`""`), dan `none` digunakan bergantian untuk merepresentasikan data kosong.
- **Format harga tidak konsisten** — campuran angka murni (`150000`) dan format `Rp150.000`.

## ⚙️ Tools yang Digunakan
- **Google BigQuery** — penyimpanan data & eksekusi query SQL
- **SQL (Standard SQL BigQuery)** — seluruh proses cleaning dilakukan murni dengan SQL, tanpa tool eksternal

## 🔧 Proses Cleaning
Proses dibagi menjadi 3 tahap menggunakan CTE (`WITH ... AS`) agar alurnya jelas dan mudah ditelusuri:

1. **`new_table`** — Normalisasi format & nilai
   - `TRIM()` dan `UPPER()`/`INITCAP()` untuk membersihkan whitespace dan menyeragamkan kapitalisasi.
   - `REGEXP_CONTAINS()` untuk mendeteksi pola format tanggal dan jam, lalu `PARSE_DATE()` / `PARSE_TIME()` untuk mengonversinya ke format standar.
   - `CASE WHEN ... IN (...)` untuk mendeteksi berbagai variasi nilai null (`nan`, `null`, `n/a`, `none`, `-`) dan menyeragamkannya menjadi `NULL` SQL yang sesungguhnya.
   - `REGEXP_REPLACE()` untuk membersihkan simbol `Rp` dan `.` dari kolom harga.
   - `SELECT DISTINCT` untuk membuang baris duplikat.

2. **`new_tipe_data`** — Konversi tipe data
   - `CAST(... AS DATE)`, `CAST(... AS TIME)`, dan `CAST(... AS INT64)` untuk memastikan setiap kolom memiliki tipe data yang benar dan siap dianalisis (bukan lagi `STRING`).

3. **`clean_table`** — Penanganan nilai kosong (fallback)
   - `COALESCE()` digunakan untuk mengisi nilai `NULL` pada kolom kategorikal dengan nilai default (`'UNKNOWN'` untuk `nama_kereta`, `nomor_kereta`, `stasiun_asal`, `stasiun_tujuan`, `kelas`; `'Waiting'` untuk `status`), sehingga tidak ada `NULL` yang tersisa pada kolom-kolom tersebut.
   - `tanggal_berangkat`, `jam_berangkat`, `jam_tiba`, dan `harga_tiket` tetap dibiarkan `NULL` jika gagal diproses, karena nilai default numerik/tanggal berisiko menyesatkan analisis (berbeda dengan kolom teks yang aman diberi label `'UNKNOWN'`).

## 📝 Query Final
Query lengkap tersedia di file [`query_cleaning.sql`](./query_cleaning.sql).

## ✅ Hasil
- Jumlah baris berkurang dari ±3.060 → 3.000 (duplikat berhasil dibuang lewat `DISTINCT`).
- Tidak ada lagi variasi format tanggal/jam — seluruh kolom sudah bertipe `DATE`/`TIME`.
- Tidak ada lagi variasi penulisan nilai kosong — seluruhnya sudah seragam jadi `NULL` lalu diberi fallback yang jelas.
- Kolom `harga_tiket` sudah bertipe numerik murni (`INT64`), siap untuk agregasi (`SUM`, `AVG`, dll).

## ⚠️ Known Issues / Keterbatasan
Beberapa hal yang **sengaja belum diperbaiki** pada tahap ini, dan dicatat sebagai temuan untuk iterasi berikutnya:

1. **Inkonsistensi referensial `nama_kereta` ↔ `nomor_kereta`** — satu nama kereta di data ini bisa memiliki lebih dari satu `nomor_kereta`, begitu pula sebaliknya. Ini bukan masalah *format*, melainkan masalah *konsistensi konten/referensial*, sehingga tidak bisa diselesaikan hanya dengan `TRIM`/`CAST`. Solusi yang lebih tepat adalah membuat tabel referensi (*master data*) `nama_kereta → nomor_kereta` lalu melakukan `JOIN`, bukan mengandalkan nilai apa adanya dari data mentah.
2. **Inkonsistensi rute `stasiun_asal` ↔ `stasiun_tujuan`** per nama kereta — masalahnya sama seperti poin 1.
3. Query saat ini menggunakan `SELECT DISTINCT` di seluruh kolom untuk deduplikasi. Pendekatan ini cukup untuk kasus duplikat identik, tapi tidak mendeteksi duplikat "semu" (misalnya `id_jadwal` sama tapi ada kolom lain yang berbeda nilainya).

## 💡 Pembelajaran
- Memahami perbedaan antara masalah **format** (bisa diselesaikan dengan `TRIM`, `REGEXP`, `CAST`) dan masalah **konsistensi konten/referensial** (butuh *master data* atau *business rule* tambahan, tidak cukup dengan transformasi string).
- Pentingnya menyusun proses cleaning secara bertahap (CTE per tahap) supaya query mudah dibaca, di-debug, dan diaudit.
- Pentingnya memilih strategi *fallback* yang berbeda untuk kolom teks (aman diberi label seperti `'UNKNOWN'`) vs kolom numerik/tanggal (lebih aman dibiarkan `NULL` daripada diisi angka/tanggal default yang bisa menyesatkan analisis).

## 🔄 Cara Reproduksi
1. Upload dataset mentah ke BigQuery sebagai tabel `jadwal_kereta_dirty`.
2. Jalankan query pada [`query_cleaning.sql`](./query_cleaning.sql) di BigQuery Console.
3. Simpan hasilnya sebagai tabel baru `jadwal_kereta_clean` (atau materialize sebagai `CREATE TABLE ... AS`).
