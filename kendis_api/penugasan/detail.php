<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

$id = $_GET['id'] ?? null;
if (!$id) {
    jsonError('Parameter id wajib diisi', 422);
}

$stmt = $pdo->prepare(
    "SELECT p.*, r.kode_request, r.lokasi_tujuan, r.tempat_tujuan, r.tanggal_berangkat AS req_tgl_berangkat,
            r.jam_berangkat, r.tanggal_kembali AS req_tgl_kembali, r.jam_kembali,
            r.kegiatan, r.jumlah_penumpang, r.status AS status_request, r.surat_penugasan,
            r.nama_atasan, k.nopol, k.merk, k.warna, k.foto AS foto_kendaraan,
            u.nama AS nama_pemohon, u.no_hp AS hp_pemohon, u.divisi
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     JOIN users u ON u.id = r.id_pemohon
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     WHERE p.id = :id AND p.id_driver = :uid
     LIMIT 1"
);
$stmt->execute(['id' => $id, 'uid' => $user['id']]);
$detail = $stmt->fetch();

if (!$detail) {
    jsonError('Penugasan tidak ditemukan', 404);
}

// Ambil laporan jika sudah ada
$stmtLaporan = $pdo->prepare("SELECT * FROM laporan_driver WHERE id_penugasan = :id LIMIT 1");
$stmtLaporan->execute(['id' => $id]);
$detail['laporan'] = $stmtLaporan->fetch() ?: null;

jsonSuccess($detail);
