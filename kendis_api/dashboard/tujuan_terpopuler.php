<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// Ambil 5 kota tujuan paling sering dikunjungi driver dari tabel request_kendis
$stmt = $pdo->prepare(
    "SELECT r.tempat_tujuan AS kota, COUNT(*) AS jumlah_trip
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id_driver = :uid
       AND r.status IN ('completed', 'rated')
       AND r.tempat_tujuan IS NOT NULL
       AND r.tempat_tujuan != ''
     GROUP BY r.tempat_tujuan
     ORDER BY jumlah_trip DESC
     LIMIT 5"
);
$stmt->execute(['uid' => $user['id']]);
$cities = $stmt->fetchAll();

// Jika belum ada data perjalanan selesai, gunakan semua status
if (empty($cities)) {
    $stmt = $pdo->prepare(
        "SELECT r.tempat_tujuan AS kota, COUNT(*) AS jumlah_trip
         FROM penugasan p
         JOIN request_kendis r ON r.id = p.id_request
         WHERE p.id_driver = :uid
           AND r.tempat_tujuan IS NOT NULL
           AND r.tempat_tujuan != ''
         GROUP BY r.tempat_tujuan
         ORDER BY jumlah_trip DESC
         LIMIT 5"
    );
    $stmt->execute(['uid' => $user['id']]);
    $cities = $stmt->fetchAll();
}

jsonSuccess($cities);
