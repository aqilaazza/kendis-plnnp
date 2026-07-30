<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method tidak diizinkan', 405);
}

$user = requireDriverAuth();
$pdo = getDbConnection();

$body = getJsonBody();
$idPenugasan = $body['id_penugasan'] ?? null;
$idKendaraan = $body['id_kendaraan'] ?? null;
if (!$idPenugasan || !$idKendaraan) {
    jsonError('id_penugasan dan id_kendaraan wajib diisi', 422);
}

// Pastikan penugasan ini milik driver ini, sudah disetujui atasan pool, dan
// belum pernah dipilihkan kendaraan / belum berangkat.
$check = $pdo->prepare(
    "SELECT p.*, r.id AS request_id FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id = :id AND p.id_driver = :uid LIMIT 1"
);
$check->execute(['id' => $idPenugasan, 'uid' => $user['id']]);
$penugasan = $check->fetch();

if (!$penugasan) {
    jsonError('Penugasan tidak ditemukan', 404);
}
if ($penugasan['status_validasi_atasan_pool'] !== 'approved') {
    jsonError('Penugasan belum disetujui atasan pool', 400);
}
if ($penugasan['id_kendaraan'] !== null) {
    jsonError('Kendaraan untuk penugasan ini sudah dipilih sebelumnya', 400);
}
if ((int) $penugasan['is_berangkat'] === 1) {
    jsonError('Perjalanan sudah dimulai sebelumnya', 400);
}

// Pastikan kendaraan yang dipilih benar-benar masih tersedia (mencegah dua
// driver pilih kendaraan yang sama nyaris bersamaan).
$kendaraanStmt = $pdo->prepare("SELECT * FROM kendaraan WHERE id = :id LIMIT 1");
$kendaraanStmt->execute(['id' => $idKendaraan]);
$kendaraan = $kendaraanStmt->fetch();

if (!$kendaraan) {
    jsonError('Kendaraan tidak ditemukan', 404);
}
if ($kendaraan['status'] !== 'tersedia') {
    jsonError('Kendaraan tersebut sudah tidak tersedia, silakan pilih kendaraan lain', 409);
}

$pdo->beginTransaction();
try {
    $pdo->prepare("UPDATE penugasan SET id_kendaraan = :idKendaraan, is_berangkat = 1 WHERE id = :id")
        ->execute(['idKendaraan' => $idKendaraan, 'id' => $idPenugasan]);

    $pdo->prepare("UPDATE kendaraan SET status = 'digunakan' WHERE id = :id")
        ->execute(['id' => $idKendaraan]);

    $pdo->prepare("UPDATE request_kendis SET status = 'on_trip' WHERE id = :rid")
        ->execute(['rid' => $penugasan['request_id']]);

    // Notifikasi ke pemohon — judulnya sengaja disamakan dengan yang dipakai
    // mulai.php ('Perjalanan Dimulai') karena progress tracker di Detail
    // Penugasan menarik timestamp tahap "Perjalanan" dari judul notifikasi
    // ini. Kalau judulnya diubah, sesuaikan juga query di detail.php.
    $req = $pdo->prepare("SELECT id_pemohon, kode_request FROM request_kendis WHERE id = :rid");
    $req->execute(['rid' => $penugasan['request_id']]);
    $r = $req->fetch();

    $pdo->prepare(
        "INSERT INTO notifikasi (id_user, id_request, judul, pesan, link)
         VALUES (:uid, :rid, 'Perjalanan Dimulai', :pesan, '/kendis/permintaan_saya.php')"
    )->execute([
        'uid' => $r['id_pemohon'],
        'rid' => $penugasan['request_id'],
        'pesan' => "Kendaraan {$kendaraan['nopol']} dipilih dan perjalanan dinas {$r['kode_request']} telah dimulai oleh driver.",
    ]);

    $pdo->commit();
} catch (Exception $e) {
    $pdo->rollBack();
    jsonError('Gagal memilih kendaraan: ' . $e->getMessage(), 500);
}

jsonSuccess(null, 'Kendaraan dipilih. Perjalanan dimulai, selamat bertugas!');
