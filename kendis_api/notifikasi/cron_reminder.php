<?php
/**
 * CRON REMINDER — dijalankan otomatis oleh scheduler server (bukan dari app).
 */

require_once __DIR__ . '/../config/database.php';

/**
 * Broadcast notifikasi "Kegiatan Harian Baru" ke semua driver aktif.
 *
 * Dipanggil dari:
 *  - file ini sendiri (cron, bagian #10)
 *  - notifikasi/list.php        (saat driver buka halaman lonceng)
 *  - notifikasi/badge_count.php (saat app polling badge, tiap 30 detik)
 *
 * Idempotent: kegiatan yang sudah pernah dinotifikasi (dikenali dari pesan
 * yang sama persis) tidak akan dikirim ulang, sehingga aman dipanggil
 * sesering apa pun tanpa duplikasi.
 */
function broadcastKegiatanBaru(PDO $pdo): int {
    $stmt = $pdo->prepare(
        "INSERT INTO notifikasi (id_user, id_request, kategori, tipe, judul, pesan, is_read, created_at)
         SELECT u.id, NULL, 'kegiatan', 'kegiatan_baru',
                'Kegiatan Harian Baru',
                CONCAT('Ada kegiatan harian baru: ', k.nama_kegiatan, ' ke ', k.tujuan, '.'),
                0, NOW()
         FROM kegiatan_harian k
         CROSS JOIN users u
         WHERE u.role = 'driver'
           AND u.is_active = 1
           AND k.id_driver IS NULL
           AND NOT EXISTS (
                SELECT 1 FROM notifikasi n
                WHERE n.id_user = u.id
                  AND n.tipe = 'kegiatan_baru'
                  AND n.pesan = CONCAT('Ada kegiatan harian baru: ', k.nama_kegiatan, ' ke ', k.tujuan, '.')
           )"
    );
    $stmt->execute();
    return $stmt->rowCount();
}

// =========================================================
// GUARD: isi cron hanya jalan saat file ini dipanggil langsung
// (cron CLI / buka URL di browser), bukan saat di-include.
// =========================================================
$isDirectRun =
    PHP_SAPI === 'cli'
    || (isset($_SERVER['SCRIPT_FILENAME']) && realpath($_SERVER['SCRIPT_FILENAME']) === __FILE__);

if (!$isDirectRun) {
    return;
}

$pdo = getDbConnection();

$log = [];

// =========================================================
// #3 — PENGUGASAN DIJADWALKAN HARI INI
// (kirim sekali per hari per penugasan)
// =========================================================
$stmt = $pdo->prepare(
    "INSERT INTO notifikasi (id_user, id_request, kategori, tipe, judul, pesan, is_read, created_at)
     SELECT p.id_driver, r.id, 'penugasan', 'penugasan_dijadwalkan_hari_ini',
            'Pengugasan Dijadwalkan Hari Ini',
            CONCAT('Pengugasan ', r.kode_request, ' ke ', r.tempat_tujuan,
                   ' dijadwalkan berangkat hari ini pukul ', TIME_FORMAT(r.jam_berangkat, '%H:%i'), '.'),
            0, NOW()
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.status_validasi_atasan_pool = 'approved'
       AND p.is_berangkat = 0
       AND r.tanggal_berangkat = CURDATE()
       AND NOT EXISTS (
            SELECT 1 FROM notifikasi n
            WHERE n.id_user = p.id_driver AND n.id_request = r.id
              AND n.tipe = 'penugasan_dijadwalkan_hari_ini'
              AND DATE(n.created_at) = CURDATE()
       )"
);
$stmt->execute();
$log['dijadwalkan_hari_ini'] = $stmt->rowCount();

// =========================================================
// #4 — PENGUGASAN AKAN DIMULAI DALAM 1 JAM
// =========================================================
$stmt = $pdo->prepare(
    "INSERT INTO notifikasi (id_user, id_request, kategori, tipe, judul, pesan, is_read, created_at)
     SELECT p.id_driver, r.id, 'penugasan', 'penugasan_akan_dimulai',
            'Pengugasan Akan Dimulai',
            CONCAT('Pengugasan ', r.kode_request, ' ke ', r.tempat_tujuan,
                   ' akan dimulai sekitar 1 jam lagi.'),
            0, NOW()
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.status_validasi_atasan_pool = 'approved'
       AND p.is_berangkat = 0
       AND TIMESTAMP(r.tanggal_berangkat, r.jam_berangkat)
             BETWEEN DATE_ADD(NOW(), INTERVAL 45 MINUTE) AND DATE_ADD(NOW(), INTERVAL 75 MINUTE)
       AND NOT EXISTS (
            SELECT 1 FROM notifikasi n
            WHERE n.id_user = p.id_driver AND n.id_request = r.id
              AND n.tipe = 'penugasan_akan_dimulai'
       )"
);
$stmt->execute();
$log['akan_dimulai'] = $stmt->rowCount();

// =========================================================
// #7 — KENDARAAN BELUM DIPILIH
// (H-1 sampai hari-H, kirim sekali per hari)
// =========================================================
$stmt = $pdo->prepare(
    "INSERT INTO notifikasi (id_user, id_request, kategori, tipe, judul, pesan, is_read, created_at)
     SELECT p.id_driver, r.id, 'penugasan', 'kendaraan_belum_dipilih',
            'Kendaraan Belum Dipilih',
            CONCAT('Kendaraan untuk pengugasan ', r.kode_request, ' ke ', r.tempat_tujuan,
                   ' belum dipilih. Segera pilih kendaraan.'),
            0, NOW()
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.status_validasi_atasan_pool = 'approved'
       AND p.is_berangkat = 0
       AND p.id_kendaraan IS NULL
       AND r.tanggal_berangkat <= DATE_ADD(CURDATE(), INTERVAL 1 DAY)
       AND NOT EXISTS (
            SELECT 1 FROM notifikasi n
            WHERE n.id_user = p.id_driver AND n.id_request = r.id
              AND n.tipe = 'kendaraan_belum_dipilih'
              AND DATE(n.created_at) = CURDATE()
       )"
);
$stmt->execute();
$log['kendaraan_belum_dipilih'] = $stmt->rowCount();

// =========================================================
// #8 — PENGUGASAN SELESAI, SILAKAN ISI LAPORAN
// =========================================================
$stmt = $pdo->prepare(
    "INSERT INTO notifikasi (id_user, id_request, kategori, tipe, judul, pesan, is_read, created_at)
     SELECT p.id_driver, r.id, 'laporan', 'laporan_perlu_diisi',
            'Pengugasan Selesai - Isi Laporan',
            CONCAT('Pengugasan ', r.kode_request, ' telah selesai. Silakan isi laporan perjalanan Anda.'),
            0, NOW()
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN laporan_driver ld ON ld.id_penugasan = p.id
     WHERE p.is_berangkat = 1
       AND (ld.id IS NULL OR ld.odo_stop IS NULL OR ld.odo_stop = 0)
       AND r.tanggal_kembali <= CURDATE()
       AND NOT EXISTS (
            SELECT 1 FROM notifikasi n
            WHERE n.id_user = p.id_driver AND n.id_request = r.id
              AND n.tipe = 'laporan_perlu_diisi'
       )"
);
$stmt->execute();
$log['laporan_perlu_diisi'] = $stmt->rowCount();

// =========================================================
// #9 — LAPORAN PERJALANAN BELUM DIISI
// =========================================================
$stmt = $pdo->prepare(
    "INSERT INTO notifikasi (id_user, id_request, kategori, tipe, judul, pesan, is_read, created_at)
     SELECT p.id_driver, r.id, 'laporan', 'laporan_belum_diisi',
            'Laporan Perjalanan Belum Diisi',
            CONCAT('Laporan perjalanan untuk pengugasan ', r.kode_request,
                   ' masih belum diisi. Mohon segera dilengkapi.'),
            0, NOW()
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN laporan_driver ld ON ld.id_penugasan = p.id
     WHERE p.is_berangkat = 1
       AND (ld.id IS NULL OR ld.odo_stop IS NULL OR ld.odo_stop = 0)
       AND r.tanggal_kembali < CURDATE()
       AND NOT EXISTS (
            SELECT 1 FROM notifikasi n
            WHERE n.id_user = p.id_driver AND n.id_request = r.id
              AND n.tipe = 'laporan_belum_diisi'
              AND DATE(n.created_at) = CURDATE()
       )"
);
$stmt->execute();
$log['laporan_belum_diisi'] = $stmt->rowCount();

// =========================================================
// #10 — KEGIATAN HARIAN BARU MASUK
// (broadcast ke semua driver aktif, sekali per kegiatan per driver;
//  idempotent, aman dipanggil juga oleh list.php / badge_count.php)
// =========================================================
$log['kegiatan_baru'] = broadcastKegiatanBaru($pdo);

// =========================================================
// OUTPUT LOG (buat cek manual di browser/CLI, bukan dikonsumsi app)
// =========================================================
echo "Cron reminder selesai jalan pada " . date('Y-m-d H:i:s') . "\n";
foreach ($log as $tipe => $jumlah) {
    echo "- $tipe: $jumlah notifikasi baru\n";
}