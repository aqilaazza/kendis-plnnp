<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// Penugasan aktif (belum selesai)
$stmt = $pdo->prepare(
    "SELECT p.*, r.kode_request, r.tempat_tujuan, r.tanggal_berangkat AS req_tgl_berangkat,
            r.jam_berangkat, r.kegiatan, r.status AS status_request,
            k.nopol, k.merk, k.warna
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     WHERE p.id_driver = :uid
       AND r.status NOT IN ('completed', 'rated', 'cancelled')
     ORDER BY p.created_at DESC"
);
$stmt->execute(['uid' => $user['id']]);
$penugasanAktif = $stmt->fetchAll();

// Statistik ringkas
$stmtCount = $pdo->prepare(
    "SELECT
        SUM(CASE WHEN r.status IN ('completed','rated') THEN 1 ELSE 0 END) AS selesai,
        SUM(CASE WHEN r.status NOT IN ('completed','rated','cancelled') THEN 1 ELSE 0 END) AS aktif,
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
