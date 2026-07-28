<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// ?periode=bulan_ini (default) | minggu_ini
$periode = $_GET['periode'] ?? 'bulan_ini';

$today = new DateTime();
if ($periode === 'minggu_ini') {
    $start = (clone $today)->modify('monday this week')->format('Y-m-d 00:00:00');
    $end = (clone $today)->modify('sunday this week')->format('Y-m-d 23:59:59');
} else {
    $start = $today->format('Y-m-01 00:00:00');
    $end = $today->format('Y-m-t 23:59:59');
}

$stmt = $pdo->prepare(
    "SELECT
        COUNT(ld.id) AS jumlah_laporan,
        COALESCE(SUM(
            CASE WHEN ld.odo_stop IS NOT NULL AND ld.odo_start IS NOT NULL AND ld.odo_stop >= ld.odo_start
                 THEN ld.odo_stop - ld.odo_start
                 ELSE 0 END
        ), 0) AS total_km,
        COALESCE(SUM(ld.total_pelaporan), 0) AS total_rupiah
     FROM laporan_driver ld
     JOIN penugasan p ON p.id = ld.id_penugasan
     WHERE p.id_driver = :uid
       AND ld.created_at BETWEEN :start AND :end"
);
$stmt->execute(['uid' => $user['id'], 'start' => $start, 'end' => $end]);
$ringkasan = $stmt->fetch();

jsonSuccess([
    'periode' => $periode,
    'jumlah_laporan' => (int) $ringkasan['jumlah_laporan'],
    'total_km' => (int) $ringkasan['total_km'],
    'total_rupiah' => (float) $ringkasan['total_rupiah'],
]);