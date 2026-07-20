<?php
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// Filter opsional lewat query string: ?status=aktif|selesai|semua (default semua)
$filter = $_GET['status'] ?? 'semua';

$where = "p.id_driver = :uid";
if ($filter === 'aktif') {
    $where .= " AND r.status NOT IN ('completed','rated','cancelled')";
} elseif ($filter === 'selesai') {
    $where .= " AND r.status IN ('completed','rated')";
}

$stmt = $pdo->prepare(
    "SELECT p.*, r.kode_request, r.tempat_tujuan, r.tanggal_berangkat AS req_tgl_berangkat,
            r.jam_berangkat, r.tanggal_kembali AS req_tgl_kembali, r.jam_kembali,
            r.kegiatan, r.jumlah_penumpang, r.status AS status_request,
            k.nopol, k.merk, k.warna
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     WHERE $where
     ORDER BY p.tanggal_berangkat DESC, p.created_at DESC"
);
$stmt->execute(['uid' => $user['id']]);
$list = $stmt->fetchAll();

jsonSuccess($list);
