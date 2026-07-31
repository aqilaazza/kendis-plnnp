<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// Ambil 10 aktivitas terbaru: gabungan perjalanan selesai + pengisian BBM
$stmt = $pdo->prepare(
    "SELECT
        'perjalanan' AS jenis,
        CONCAT('Perjalanan ke ', r.tempat_tujuan) AS judul,
        CONCAT(k.nopol, ' • Selesai ', DATE_FORMAT(ld.created_at, '%H:%i')) AS subjudul,
        COALESCE(CONCAT(ld.odo_stop - ld.odo_start, ' Km'), '0 Km') AS nilai,
        'km' AS satuan,
        'Reguler' AS status
     FROM laporan_driver ld
     JOIN penugasan p ON p.id = ld.id_penugasan
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     WHERE p.id_driver = :uid
       AND r.status IN ('completed', 'rated')
     ORDER BY ld.created_at DESC
     LIMIT 10"
);
$stmt->execute(['uid' => $user['id']]);
$trips = $stmt->fetchAll();

// Jika belum ada data laporan, ambil dari penugasan selesai tanpa laporan
if (empty($trips)) {
    $stmt = $pdo->prepare(
        "SELECT
            'perjalanan' AS jenis,
            CONCAT('Perjalanan ke ', r.tempat_tujuan) AS judul,
            CONCAT(COALESCE(k.nopol, ''), ' • Selesai') AS subjudul,
            '0 Km' AS nilai,
            'km' AS satuan,
            r.status AS status
         FROM penugasan p
         JOIN request_kendis r ON r.id = p.id_request
         LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
         WHERE p.id_driver = :uid
           AND r.status IN ('completed', 'rated', 'on_trip')
         ORDER BY p.created_at DESC
         LIMIT 10"
    );
    $stmt->execute(['uid' => $user['id']]);
    $trips = $stmt->fetchAll();
}

jsonSuccess($trips);
