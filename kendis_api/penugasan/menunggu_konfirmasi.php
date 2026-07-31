<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

$stmt = $pdo->prepare(
    "SELECT 
        p.id,
        r.kode_request,
        r.lokasi_tujuan,
        r.tempat_tujuan,
        r.tanggal_berangkat,
        r.jam_berangkat,
        r.status AS status_request,
        CASE WHEN r.tanggal_berangkat <= DATE_ADD(CURDATE(), INTERVAL 2 DAY) THEN 1 ELSE 0 END AS is_urgent
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id_driver = :uid
       AND r.status = 'driver_assigned'
       AND p.is_berangkat = 0
     ORDER BY is_urgent DESC, r.tanggal_berangkat ASC, r.jam_berangkat ASC"
);
$stmt->execute(['uid' => $user['id']]);
$list = $stmt->fetchAll();

$result = array_map(function ($row) {
    return [
        'id' => (int) $row['id'],
        'kode_request' => $row['kode_request'],
        'is_urgent' => $row['is_urgent'] == '1',
        'lokasi_tujuan' => $row['lokasi_tujuan'] ?? '',
        'tempat_tujuan' => $row['tempat_tujuan'],
        'tanggal_berangkat' => $row['tanggal_berangkat'],
        'jam_berangkat' => $row['jam_berangkat'],
        'status' => $row['status_request'],
    ];
}, $list);

jsonSuccess($result);
