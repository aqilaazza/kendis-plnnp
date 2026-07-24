<?php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();
$uid = (int)$user['id'];

// ──────────────────────────────────────────────
// 1. Ringkasan Tugas
// ──────────────────────────────────────────────
// Tugas Aktif: semua status selain completed/rated/cancelled
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS cnt
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id_driver = :uid
       AND r.status NOT IN ('completed','rated','cancelled')"
);
$stmt->execute(['uid' => $uid]);
$activeTasks = (int)$stmt->fetch()['cnt'];

// Tugas Selesai Minggu ini
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS cnt
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id_driver = :uid
       AND r.status IN ('completed','rated')
       AND YEARWEEK(p.tanggal_berangkat) = YEARWEEK(CURDATE())"
);
$stmt->execute(['uid' => $uid]);
$completedWeek = (int)$stmt->fetch()['cnt'];

// ──────────────────────────────────────────────
// 2. Biaya Dilaporkan
// ──────────────────────────────────────────────
$stmt = $pdo->prepare(
    "SELECT COALESCE(SUM(ld.total_pelaporan), 0) AS total_cost,
            COUNT(ld.id) AS receipt_count
     FROM laporan_driver ld
     JOIN penugasan p ON p.id = ld.id_penugasan
     WHERE p.id_driver = :uid"
);
$stmt->execute(['uid' => $uid]);
$costRow = $stmt->fetch();
$totalCost = (float)$costRow['total_cost'];
$receiptCount = (int)$costRow['receipt_count'];

// Tugas selesai yang belum lapor biaya
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS cnt
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id_driver = :uid
       AND r.status IN ('completed','rated')
       AND NOT EXISTS (
           SELECT 1 FROM laporan_driver ld WHERE ld.id_penugasan = p.id
       )"
);
$stmt->execute(['uid' => $uid]);
$needReport = (int)$stmt->fetch()['cnt'];

// ──────────────────────────────────────────────
// 3. Cost Periode (6 bulan terakhir, per kategori)
// ──────────────────────────────────────────────
$stmt = $pdo->prepare(
    "SELECT DATE_FORMAT(p.tanggal_berangkat, '%Y-%m') AS month_key,
            DATE_FORMAT(p.tanggal_berangkat, '%b %Y') AS month_label,
            COALESCE(SUM(ld.rupiah_bbm), 0) AS bbm,
            COALESCE(SUM(ld.rupiah_parkir), 0) AS parkir,
            COALESCE(SUM(ld.rupiah_tol), 0) AS tol
     FROM penugasan p
     LEFT JOIN laporan_driver ld ON ld.id_penugasan = p.id
     WHERE p.id_driver = :uid
       AND p.tanggal_berangkat >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 5 MONTH), '%Y-%m-01')
     GROUP BY DATE_FORMAT(p.tanggal_berangkat, '%Y-%m'), DATE_FORMAT(p.tanggal_berangkat, '%b %Y')
     ORDER BY DATE_FORMAT(p.tanggal_berangkat, '%Y-%m') ASC"
);
$stmt->execute(['uid' => $uid]);
$costRows = $stmt->fetchAll();

$costPeriod = [];
$monthMap = [];
foreach ($costRows as $r) {
    $monthMap[$r['month_key']] = [
        'month'  => $r['month_label'],
        'bbm'    => (float)$r['bbm'],
        'parkir' => (float)$r['parkir'],
        'tol'    => (float)$r['tol'],
    ];
}

// Generate 6 bulan berurutan (termasuk bulan berjalan)
for ($i = 5; $i >= 0; $i--) {
    $dt = new DateTime("first day of -$i months");
    $key = $dt->format('Y-m');
    $label = $dt->format('M Y');
    if (isset($monthMap[$key])) {
        $costPeriod[] = $monthMap[$key];
    } else {
        $costPeriod[] = [
            'month'  => $label,
            'bbm'    => 0,
            'parkir' => 0,
            'tol'    => 0,
        ];
    }
}

// ──────────────────────────────────────────────
// 4. Tujuan Dinas Terpopuler (top 5)
// ──────────────────────────────────────────────
$stmt = $pdo->prepare(
    "SELECT COALESCE(kt.nama_kota, r.tempat_tujuan) AS city,
            COUNT(*) AS trip_count
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kota_tujuan kt ON kt.id = r.id_kota
     WHERE p.id_driver = :uid
     GROUP BY city
     ORDER BY trip_count DESC
     LIMIT 5"
);
$stmt->execute(['uid' => $uid]);
$popularDestinations = $stmt->fetchAll();

// Cast types
$popularDestinations = array_map(function ($d) {
    return [
        'city'       => $d['city'],
        'trip_count' => (int)$d['trip_count'],
    ];
}, $popularDestinations);

// ──────────────────────────────────────────────
// 5. Aktivitas Terakhir
// ──────────────────────────────────────────────
$stmt = $pdo->prepare(
    "(SELECT
         'trip' AS type,
         CONCAT('Perjalanan ke ', r.tempat_tujuan) AS title,
         CONCAT(COALESCE(k.nopol, '-'), ' • Selesai ', COALESCE(DATE_FORMAT(r.jam_kembali, '%H:%i'), '-')) AS subtitle,
         CASE WHEN ld.odo_stop IS NOT NULL AND ld.odo_start IS NOT NULL
           THEN CONCAT(CAST((ld.odo_stop - ld.odo_start) AS CHAR), ' Km')
           ELSE NULL
         END AS `value`,
         CASE WHEN r.status IN ('completed','rated') THEN 'Selesai' ELSE 'Reguler' END AS status,
         COALESCE(ld.created_at, p.created_at) AS activity_date
      FROM penugasan p
      JOIN request_kendis r ON r.id = p.id_request
      LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
      LEFT JOIN laporan_driver ld ON ld.id_penugasan = p.id
      WHERE p.id_driver = ?
      ORDER BY activity_date DESC
      LIMIT 5)
    UNION ALL
    (SELECT
         'expense' AS type,
         'Pengisian Bahan Bakar' AS title,
         CONCAT('Nota #', ld.id) AS subtitle,
         CONCAT('Rp ', FORMAT(ld.rupiah_bbm, 0)) AS `value`,
         'Divalidasi' AS status,
         ld.created_at AS activity_date
      FROM laporan_driver ld
      JOIN penugasan p ON p.id = ld.id_penugasan
      WHERE p.id_driver = ?
      ORDER BY ld.created_at DESC
      LIMIT 5)
    ORDER BY activity_date DESC
    LIMIT 5"
);
$stmt->execute([$uid, $uid]);
$activities = $stmt->fetchAll();

// ──────────────────────────────────────────────
// 6. Notifikasi belum dibaca
// ──────────────────────────────────────────────
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS cnt FROM notifikasi WHERE id_user = :uid AND is_read = 0"
);
$stmt->execute(['uid' => $uid]);
$unreadNotif = (int)$stmt->fetch()['cnt'];

// ──────────────────────────────────────────────
// Response
// ──────────────────────────────────────────────
jsonSuccess([
    'driver' => [
        'id'   => (int)$user['id'],
        'name' => $user['nama'] ?: 'Driver',
        'role' => $user['jabatan'] ?: 'Driver Operasional',
    ],
    'summary' => [
        'active_tasks'         => $activeTasks,
        'completed_tasks_week' => $completedWeek,
        'reported_cost_total'  => $totalCost,
        'receipt_count'        => $receiptCount,
        'tasks_need_report'    => $needReport,
    ],
    'notifikasi_belum_dibaca' => $unreadNotif,
    'cost_period'            => $costPeriod,
    'popular_destinations'   => $popularDestinations,
    'recent_activities'      => $activities,
]);
