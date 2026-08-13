-- Jalankan file ini di phpMyAdmin pada database kendis_upptn (sekali saja)
-- Menambahkan kolom id_kegiatan pada tabel notifikasi untuk dedup notifikasi
-- "Kegiatan Harian Baru" per kegiatan (bukan per teks pesan).

ALTER TABLE `notifikasi`
  ADD COLUMN `id_kegiatan` int(11) DEFAULT NULL AFTER `id_request`,
  ADD KEY `idx_notifikasi_kegiatan` (`id_kegiatan`);
