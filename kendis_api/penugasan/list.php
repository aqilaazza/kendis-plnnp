<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// Filter opsional lewat query string: ?status=aktif|selesai|semua (default semua)
$filter = $_GET['status'] ?? 'semua';
// Pencarian bebas: ?q=... — dicocokkan ke kode request, kegiatan,
// tempat/lokasi tujuan, dan nopol kendaraan.
$search = trim($_GET['q'] ?? '');

$where = "p.id_driver = :uid";
$params = ['uid' => $user['id']];

if ($filter === 'aktif') {
    // FIX: disamakan dengan definisi "aktif" di profil/dashboard.php —
    // hanya hitung penugasan yang SUDAH BERANGKAT (is_berangkat = 1),
    // bukan semua status selain completed/rated/cancelled. Sebelumnya
    // penugasan yang baru "approved_pool" (belum berangkat) ikut
    // terhitung di sini, sehingga jumlahnya beda dengan card di
    // Dashboard.
    $where .= " AND r.status NOT IN ('completed','rated','cancelled')
                AND p.is_berangkat = 1";
} elseif ($filter === 'selesai') {
    $where .= " AND r.status IN ('completed','rated')";
}

if ($search !== '') {
    $where .= " AND (r.kode_request LIKE :q1 OR r.kegiatan LIKE :q2
                 OR r.tempat_tujuan LIKE :q3 OR r.lokasi_tujuan LIKE :q4
                 OR k.nopol LIKE :q5)";
    $like = '%' . $search . '%';
    $params['q1'] = $like;
    $params['q2'] = $like;
    $params['q3'] = $like;
    $params['q4'] = $like;
    $params['q5'] = $like;
}

$stmt = $pdo->prepare(
    "SELECT p.*, r.kode_request, r.tempat_tujuan, r.lokasi_tujuan, r.tanggal_berangkat AS req_tgl_berangkat,
            r.jam_berangkat, r.tanggal_kembali AS req_tgl_kembali, r.jam_kembali,
            r.kegiatan, r.jumlah_penumpang, r.status AS status_request,
            k.nopol, k.merk, k.warna,
            up.nama AS nama_pemohon, up.no_hp AS hp_pemohon,
            ld.total_pelaporan, ld.odo_start, ld.odo_stop,
            ld.liter_bbm, ld.rupiah_bbm, ld.rupiah_tol, ld.rupiah_parkir,
            ld.foto_bbm, ld.foto_tol, ld.foto_parkir,
            ld.created_at AS tanggal_lapor
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     LEFT JOIN users up ON up.id = r.id_pemohon
     LEFT JOIN laporan_driver ld ON ld.id_penugasan = p.id
     WHERE $where
     ORDER BY p.tanggal_berangkat DESC, p.created_at DESC"
);
$stmt->execute($params);
$list = $stmt->fetchAll();

jsonSuccess($list);