# Plan: Implementasi Dashboard Driver (Sesuai Desain Figma) + Integrasi MySQL

## Konteks
Aplikasi Flutter (Kendis - Driver Operasional) sudah punya dashboard dengan card summary
(Tugas Aktif, Tugas Selesai, Biaya Dilaporkan) yang **sudah berfungsi**. Namun 3 komponen
berikut masih menampilkan empty state ("Data belum tersedia") dan perlu diimplementasikan
agar sesuai desain Figma:

1. **Cost Periode** → line chart (BBM, Parkir, Tol per bulan)
2. **Tujuan Dinas Terpopuler** → donut chart (top 5 kota tujuan)
3. **Aktivitas Terakhir** → list aktivitas terbaru (perjalanan, pengisian BBM, dll)

Backend: **MySQL**. Asumsi: sudah ada (atau perlu dibuat) REST API di atas MySQL untuk
diakses Flutter — karena Flutter tidak connect langsung ke MySQL. Jika API belum ada,
task 1 di bawah mencakup pembuatannya.

---

## Step 0 — Discovery (WAJIB dijalankan lebih dulu oleh opencode)
Sebelum menulis kode apa pun, eksplorasi codebase untuk memetakan hal-hal berikut,
karena plan ini akan disesuaikan dengan temuan aktual:

- [ ] Cek struktur project Flutter: state management yang dipakai (Provider/Riverpod/Bloc/GetX)
- [ ] Cek folder services/repository yang sudah ada untuk fetch data dashboard (yang sudah
      berhasil menampilkan Tugas Aktif/Selesai & Biaya Dilaporkan) — jadikan pola/konvensi acuan
- [ ] Cek apakah sudah ada backend REST API (folder terpisah / repo terpisah?) atau Flutter
      masih pakai dummy/local data untuk card yang sudah jalan
- [ ] Cek skema tabel MySQL yang relevan: tugas, laporan_biaya, nota, perjalanan/trip,
      pengisian_bbm, kota_tujuan
- [ ] Cek package chart yang sudah ter-install di `pubspec.yaml` (fl_chart? syncfusion? none?)
- [ ] Screenshot/kode widget dashboard existing (`dashboard_page.dart` atau sejenisnya) untuk
      tahu di titik mana placeholder "Data belum tersedia" itu ditulis

Laporkan temuan step 0 sebelum lanjut ke step berikutnya.

---

## Step 1 — Backend: Endpoint API (jika belum ada)
Buat/lengkapi REST API di atas MySQL dengan endpoint berikut (sesuaikan nama/framework
dengan yang ditemukan di Step 0, mis. Laravel/Express/Node):

| Endpoint | Fungsi | Response |
|---|---|---|
| `GET /api/dashboard/cost-period?range=6m` | Data biaya per periode untuk line chart | array `{ month, bbm, parkir, tol }` |
| `GET /api/dashboard/top-destinations?limit=5` | Kota tujuan tersering untuk donut chart | array `{ kota, jumlah_trip, persentase }` |
| `GET /api/dashboard/recent-activities?limit=5` | Aktivitas terakhir | array `{ id, tipe, judul, keterangan, nominal_or_jarak, waktu, status }` |

Query dasar (contoh, sesuaikan nama tabel/kolom asli):
```sql
-- cost-period (group by bulan, per kategori biaya)
SELECT DATE_FORMAT(tanggal, '%Y-%m') AS bulan,
       SUM(CASE WHEN kategori='bbm' THEN nominal ELSE 0 END) AS bbm,
       SUM(CASE WHEN kategori='parkir' THEN nominal ELSE 0 END) AS parkir,
       SUM(CASE WHEN kategori='tol' THEN nominal ELSE 0 END) AS tol
FROM laporan_biaya
WHERE driver_id = ? AND tanggal >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY bulan ORDER BY bulan;

-- top-destinations
SELECT kota_tujuan, COUNT(*) AS jumlah_trip
FROM perjalanan
WHERE driver_id = ?
GROUP BY kota_tujuan ORDER BY jumlah_trip DESC LIMIT 5;

-- recent-activities (union perjalanan + pengisian_bbm, order by waktu desc, limit 5)
```

Pastikan endpoint butuh auth (token driver yang login) agar data sesuai user, bukan global.

**Acceptance criteria:** endpoint bisa di-hit via Postman/curl dan mengembalikan JSON valid
sesuai driver yang login, termasuk kondisi data kosong (return array `[]`, bukan error).

---

## Step 2 — Flutter: Setup Chart Package
- Tambahkan `fl_chart` di `pubspec.yaml` (ringan, cocok untuk line chart + pie/donut chart,
  dan bisa dikustomisasi warna sesuai Figma: teal/dark-teal, hijau, kuning/gold)
- Jalankan `flutter pub get`

---

## Step 3 — Flutter: Data Layer
Ikuti pola yang sudah dipakai untuk card summary (temuan Step 0):
- [ ] Buat model: `CostPeriodModel`, `TopDestinationModel`, `RecentActivityModel`
- [ ] Buat/lengkapi method di repository/service: `getCostPeriod()`, `getTopDestinations()`,
      `getRecentActivities()` yang memanggil endpoint dari Step 1
- [ ] Tambahkan state (loading / success / empty / error) untuk masing-masing, mengikuti
      state management yang sudah dipakai project (bukan bikin pola baru)

---

## Step 4 — Flutter: Widget UI

### 4a. Cost Periode (Line Chart)
- Ganti placeholder container abu-abu dengan `LineChart` (fl_chart)
- 3 garis: BBM, Parkir, Tol — warna sesuai Figma (dark teal, hijau, gold)
- X-axis: nama bulan singkat (Feb, Mar, ... sesuai data 6 bulan terakhir)
- Legend di bawah chart dengan dot warna + label, sama seperti Figma
- Kondisi data kosong → tetap tampilkan "Data belum tersedia" (state ini dipertahankan sebagai empty state yang valid)

### 4b. Tujuan Dinas Terpopuler (Donut Chart)
- Ganti placeholder dengan `PieChart` (fl_chart, mode donut via `centerSpaceRadius`)
- Center text: kota dengan trip terbanyak + jumlah trip (mis. "SURABAYA / 12 Trip")
- Legend di bawah: dot warna + nama kota, urut sesuai jumlah trip terbanyak

### 4c. Aktivitas Terakhir (List)
- Ganti placeholder dengan `ListView.builder` (shrinkWrap, non-scrollable jika di dalam scroll parent)
- Item: ikon (truck untuk perjalanan, ikon SPBU untuk pengisian BBM), judul, keterangan
  (plat nomor • waktu selesai), nominal/jarak di kanan, badge status ("Reguler"/"Divalidasi")
- Tap item → (opsional, tanya user) navigasi ke detail

**Acceptance criteria per widget:** tampil benar saat data ada, tampil empty state yang rapi
saat data kosong, tidak crash saat API gagal (tampilkan pesan error ringan, bukan blank/hang).

---

## Step 5 — Testing & Verifikasi
- [ ] Jalankan di localhost/emulator, login sebagai driver yang punya data → pastikan 3
      komponen terisi dan visual mendekati Figma (warna, layout, spacing)
- [ ] Test dengan driver yang belum ada data sama sekali → pastikan empty state tetap muncul rapi
- [ ] Test dengan koneksi API dimatikan → pastikan tidak crash
- [ ] Bandingkan screenshot hasil vs Figma untuk cek kesesuaian warna/spacing/font

---

## Urutan Eksekusi untuk opencode
1. Step 0 (discovery) → laporkan temuan
2. Step 1 (backend API) — skip jika sudah ada, cukup sesuaikan/lengkapi
3. Step 2 (package)
4. Step 3 (data layer)
5. Step 4 (UI, urutkan: cost periode → top destinations → recent activities)
6. Step 5 (testing)

Setiap step selesai, minta opencode jalankan `flutter analyze` dan pastikan tidak ada error
sebelum lanjut ke step berikutnya.