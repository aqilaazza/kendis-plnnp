<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// Ambil data biaya per kategori 6 bulan terakhir dari tabel laporan_driver
$months = [];
for ($i = 5; $i >= 0; $i--) {
    $months[] = date('Y-m', strtotime("-$i months"));
}

$monthsIndo = [
    'Jan' => 'Jan', 'Feb' => 'Feb', 'Mar' => 'Mar',
    'Apr' => 'Apr', 'May' => 'Mei', 'Jun' => 'Jun',
    'Jul' => 'Jul', 'Aug' => 'Agu', 'Sep' => 'Sep',
    'Oct' => 'Okt', 'Nov' => 'Nov', 'Dec' => 'Des',
];

$result = [];
foreach ($months as $month) {
    $stmt = $pdo->prepare(
        "SELECT
            COALESCE(SUM(ld.rupiah_bbm), 0) AS bbm,
            COALESCE(SUM(ld.rupiah_parkir), 0) AS parkir,
            COALESCE(SUM(ld.rupiah_tol), 0) AS tol
         FROM laporan_driver ld
         JOIN penugasan p ON p.id = ld.id_penugasan
         WHERE p.id_driver = :uid
           AND DATE_FORMAT(ld.created_at, '%Y-%m') = :month"
    );
    $stmt->execute(['uid' => $user['id'], 'month' => $month]);
    $row = $stmt->fetch();

    $enMonth = date('M', strtotime($month . '-01'));
    $year = date('Y', strtotime($month . '-01'));
    $label = ($monthsIndo[$enMonth] ?? $enMonth) . ' ' . $year;

    $result[] = [
        'label' => $label,
        'bbm' => (float) $row['bbm'],
        'parkir' => (float) $row['parkir'],
        'tol' => (float) $row['tol'],
    ];
}

jsonSuccess($result);
