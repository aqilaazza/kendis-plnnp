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

// NOTE: enam tanggal untuk progress tracker semuanya ditarik dari jejak yang
// SUDAH ADA di sistem (tidak perlu kolom/migration baru):
// - tanggal_diajukan       -> request_kendis.created_at
// - tanggal_persetujuan_atasan -> notifikasi 'Permintaan Disetujui Atasan'
// - tanggal_driver_ditunjuk    -> notifikasi 'Driver Telah Ditugaskan'
// - tanggal_persetujuan_pool   -> notifikasi 'Penugasan Disetujui'
// - tanggal_mulai              -> notifikasi 'Perjalanan Dimulai' (di-insert oleh mulai.php)
// - tanggal_selesai            -> laporan_driver.created_at
$stmt = $pdo->prepare(
    "SELECT p.*, r.kode_request, r.lokasi_tujuan, r.tempat_tujuan, r.tanggal_berangkat AS req_tgl_berangkat,
            r.jam_berangkat, r.tanggal_kembali AS req_tgl_kembali, r.jam_kembali,
            r.kegiatan, r.jumlah_penumpang, r.status AS status_request, r.surat_penugasan,
            r.nama_atasan, r.catatan_atasan, r.catatan_pool, r.created_at AS tanggal_diajukan,
            k.nopol, k.merk, k.warna, k.foto AS foto_kendaraan,
            u.nama AS nama_pemohon, u.no_hp AS hp_pemohon, u.divisi,
            ud.nama AS nama_driver, ud.no_hp AS hp_driver,
            (SELECT MIN(n.created_at) FROM notifikasi n WHERE n.id_request = r.id AND n.judul = 'Permintaan Disetujui Atasan') AS tanggal_persetujuan_atasan,
            (SELECT MIN(n.created_at) FROM notifikasi n WHERE n.id_request = r.id AND n.judul = 'Driver Telah Ditugaskan') AS tanggal_driver_ditunjuk,
            (SELECT MIN(n.created_at) FROM notifikasi n WHERE n.id_request = r.id AND n.judul = 'Penugasan Disetujui') AS tanggal_persetujuan_pool,
            (SELECT MIN(n.created_at) FROM notifikasi n WHERE n.id_request = r.id AND n.judul = 'Perjalanan Dimulai') AS tanggal_mulai
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     JOIN users u ON u.id = r.id_pemohon
     LEFT JOIN kendaraan k ON k.id = p.id_kendaraan
     LEFT JOIN users ud ON ud.id = p.id_driver
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
$laporan = $stmtLaporan->fetch() ?: null;
$detail['laporan'] = $laporan;

// Waktu selesai (tahap "Selesai") = waktu laporan driver dikirim.
$detail['tanggal_selesai'] = $laporan['created_at'] ?? null;
$detail['tanggal_lapor'] = $laporan['created_at'] ?? null;

jsonSuccess($detail);