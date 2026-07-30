<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();
$uid = $user['id'];

// ============================================================
// 1. COST PERIODE — 6 bulan terakhir
// ============================================================
$costPeriode = [];
$now = new DateTime('first day of this month');
for ($i = 5; $i >= 0; $i--) {
    $t = clone $now;
    $t->modify("-$i months");
    $bulan = $t->format('Y-m');
    $enMonth = $t->format('M');
    $year = $t->format('Y');

    $stmt = $pdo->prepare(
        "SELECT
            COALESCE(SUM(ld.rupiah_bbm), 0) AS bbm,
            COALESCE(SUM(ld.rupiah_parkir), 0) AS parkir,
            COALESCE(SUM(ld.rupiah_tol), 0) AS tol
         FROM laporan_driver ld
         JOIN penugasan p ON p.id = ld.id_penugasan
         WHERE p.id_driver = :uid
           AND DATE_FORMAT(ld.created_at, '%Y-%m') = :bulan"
    );
    $stmt->execute(['uid' => $uid, 'bulan' => $bulan]);
    $row = $stmt->fetch();

    $costPeriode[] = [
        'bulan' => $bulan,
        'label' => "$enMonth $year",
        'bbm' => (float) $row['bbm'],
        'parkir' => (float) $row['parkir'],
        'tol' => (float) $row['tol'],
    ];
}

// ============================================================
// 2. TUJUAN TERPOPULER — 5 kota terbanyak
// ============================================================
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
$stmt->execute(['uid' => $uid]);
$tujuanTerpopuler = $stmt->fetchAll();

// ============================================================
// 3. AKTIVITAS TERAKHIR — 5 terbaru
// ============================================================
// Catatan: tabel laporan_driver menyatu antara trip & BBM dalam satu baris.
// Tidak ada event terpisah untuk "pengisian BBM" tanpa perjalanan.
// Maka semua aktivitas dikirim sebagai jenis "perjalanan" dengan nilai = km.
$stmt = $pdo->prepare(
    "    SELECT
        'perjalanan' AS jenis,
        CONCAT('Perjalanan ke ', r.tempat_tujuan) AS judul,
        CONCAT(COALESCE(CONCAT(k.nopol, ' • '), ''), 'Selesai ', DATE_FORMAT(ld.created_at, '%H:%i')) AS subjudul,
        ld.created_at AS waktu,
        CAST(CASE WHEN ld.odo_stop IS NOT NULL AND ld.odo_start IS NOT NULL AND ld.odo_stop >= ld.odo_start
             THEN ld.odo_stop - ld.odo_start
             ELSE 0 END AS CHAR) AS nilai,
        'km' AS satuan,
        'Reguler' AS status,
        r.kode_request,
        p.id AS id_penugasan
     FROM laporan_driver ld
     JOIN penugasan p ON p.id = ld.id_penugasan
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     WHERE p.id_driver = :uid
     ORDER BY ld.created_at DESC
     LIMIT 5"
);
$stmt->execute(['uid' => $uid]);
$aktivitasTerakhir = $stmt->fetchAll();

// ============================================================
// 4. PERLU LAPORAN — penugasan sudah berangkat, laporan belum ada
// ============================================================
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS count
     FROM penugasan p
     WHERE p.id_driver = :uid
       AND p.is_berangkat = 1
       AND NOT EXISTS (
           SELECT 1 FROM laporan_driver ld WHERE ld.id_penugasan = p.id
       )"
);
$stmt->execute(['uid' => $uid]);
$perluLaporan = (int) $stmt->fetch()['count'];

// ============================================================
// 5. NOTIFIKASI BELUM DIBACA
// ============================================================
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS count FROM notifikasi WHERE id_user = :uid AND is_read = 0"
);
$stmt->execute(['uid' => $uid]);
$notifUnread = (int) $stmt->fetch()['count'];

// ============================================================
// RESPONSE
// ============================================================
jsonSuccess([
    'cost_periode' => $costPeriode,
    'tujuan_terpopuler' => $tujuanTerpopuler,
    'aktivitas_terakhir' => $aktivitasTerakhir,
    'perlu_laporan' => $perluLaporan,
    'notifikasi_belum_dibaca' => $notifUnread,
]);
