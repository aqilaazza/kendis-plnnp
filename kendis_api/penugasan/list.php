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
    "SELECT p.*, r.kode_request, r.tempat_tujuan, r.lokasi_tujuan, r.tanggal_berangkat AS req_tgl_berangkat,
            r.jam_berangkat, r.tanggal_kembali AS req_tgl_kembali, r.jam_kembali,
            r.kegiatan, r.jumlah_penumpang, r.status AS status_request,
            k.nopol, k.merk, k.warna,
            up.nama AS nama_pemohon, up.no_hp AS hp_pemohon,
            ld.total_pelaporan, ld.odo_start, ld.odo_stop
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     LEFT JOIN users up ON up.id = r.id_pemohon
     LEFT JOIN laporan_driver ld ON ld.id_penugasan = p.id
     WHERE $where
     ORDER BY p.tanggal_berangkat DESC, p.created_at DESC"
);
$stmt->execute(['uid' => $user['id']]);
$list = $stmt->fetchAll();

jsonSuccess($list);