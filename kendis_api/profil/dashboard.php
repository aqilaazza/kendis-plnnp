<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// Penugasan aktif (sedang berjalan). Definisi "aktif" di sini SENGAJA
// disamakan persis dengan statistik.tugas_aktif di bawah (is_berangkat = 1)
// -- supaya list ini dan angka count-nya konsisten dalam 1 response yang
// sama. Kalau nanti butuh list "tugas yang masih perlu di-follow-up driver
// tapi belum berangkat", itu beda konsep -- pakai endpoint
// penugasan/menunggu_konfirmasi.php, bukan nambah kondisi lain di sini.
$stmt = $pdo->prepare(
    "SELECT p.*, r.kode_request, r.tempat_tujuan, r.tanggal_berangkat AS req_tgl_berangkat,
            r.jam_berangkat, r.kegiatan, r.status AS status_request,
            k.nopol, k.merk, k.warna
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     WHERE p.id_driver = :uid
       AND r.status NOT IN ('completed', 'rated', 'cancelled')
       AND p.is_berangkat = 1
     ORDER BY p.created_at DESC"
);
$stmt->execute(['uid' => $user['id']]);
$penugasanAktif = $stmt->fetchAll();

// ============================================================
// Statistik ringkas
// ------------------------------------------------------------
// FIX: "tugas_selesai" sekarang difilter untuk MINGGU INI saja
// (Senin s.d. hari ini), sesuai label UI "Minggu ini" di dashboard.
// Sebelumnya query menghitung SEMUA tugas selesai sepanjang waktu
// (all-time), tidak sesuai dengan label yang ditampilkan.
//
// ASUMSI: kolom yang menandai "kapan status berubah jadi selesai"
// adalah r.updated_at. Kalau ternyata kolom itu bukan sumber yang
// tepat (mis. ada kolom khusus seperti r.tanggal_selesai), ganti
// SEMUA pemakaian r.updated_at di query $stmtCount di bawah ini
// dengan nama kolom yang benar.
//
// FIX #2: "tugas_aktif" sekarang hanya menghitung penugasan yang
// SUDAH BERANGKAT (p.is_berangkat = 1). Sebelumnya semua status
// selain completed/rated/cancelled dihitung aktif, termasuk yang
// baru "approved_pool" tapi belum berangkat — sehingga angka
// tampak lebih besar dari yang sebenarnya sedang berjalan.
// ============================================================
$stmtCount = $pdo->prepare(
    "SELECT
        SUM(CASE WHEN r.status IN ('completed','rated')
                 AND r.updated_at >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)
            THEN 1 ELSE 0 END) AS selesai,
        SUM(CASE WHEN r.status NOT IN ('completed','rated','cancelled')
                 AND p.is_berangkat = 1
            THEN 1 ELSE 0 END) AS aktif,
        COUNT(*) AS total
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id_driver = :uid"
);
$stmtCount->execute(['uid' => $user['id']]);
$stats = $stmtCount->fetch();

// Rata-rata rating
$stmtRating = $pdo->prepare(
    "SELECT ROUND(AVG(bintang), 1) AS rata_rating, COUNT(*) AS jumlah_penilaian
     FROM penilaian_driver WHERE id_driver = :uid"
);
$stmtRating->execute(['uid' => $user['id']]);
$rating = $stmtRating->fetch();

// Notifikasi belum dibaca
$stmtNotif = $pdo->prepare(
    "SELECT COUNT(*) AS belum_dibaca FROM notifikasi WHERE id_user = :uid AND is_read = 0"
);
$stmtNotif->execute(['uid' => $user['id']]);
$notif = $stmtNotif->fetch();

jsonSuccess([
    'user' => $user,
    'penugasan_aktif' => $penugasanAktif,
    'statistik' => [
        'total_tugas' => (int)$stats['total'],
        'tugas_selesai' => (int)$stats['selesai'],
        'tugas_aktif' => (int)$stats['aktif'],
        'rata_rating' => $rating['rata_rating'] !== null ? (float)$rating['rata_rating'] : null,
        'jumlah_penilaian' => (int)$rating['jumlah_penilaian'],
    ],
    'notifikasi_belum_dibaca' => (int)$notif['belum_dibaca'],
]);