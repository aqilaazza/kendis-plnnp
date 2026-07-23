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
if (!$idPenugasan) {
    jsonError('id_penugasan wajib diisi', 422);
}

// Pastikan penugasan milik driver ini dan sudah disetujui atasan pool
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
if ((int)$penugasan['is_berangkat'] === 1) {
    jsonError('Perjalanan sudah dimulai sebelumnya', 400);
}

$pdo->beginTransaction();
try {
    $pdo->prepare("UPDATE penugasan SET is_berangkat = 1 WHERE id = :id")
        ->execute(['id' => $idPenugasan]);

    $pdo->prepare("UPDATE request_kendis SET status = 'on_trip' WHERE id = :rid")
        ->execute(['rid' => $penugasan['request_id']]);

    // Notifikasi ke pemohon
    $req = $pdo->prepare("SELECT id_pemohon, kode_request FROM request_kendis WHERE id = :rid");
    $req->execute(['rid' => $penugasan['request_id']]);
    $r = $req->fetch();

    $pdo->prepare(
        "INSERT INTO notifikasi (id_user, id_request, judul, pesan, link)
         VALUES (:uid, :rid, 'Perjalanan Dimulai', :pesan, '/kendis/permintaan_saya.php')"
    )->execute([
        'uid' => $r['id_pemohon'],
        'rid' => $penugasan['request_id'],
        'pesan' => "Perjalanan dinas {$r['kode_request']} telah dimulai oleh driver.",
    ]);

    $pdo->commit();
} catch (Exception $e) {
    $pdo->rollBack();
    jsonError('Gagal memulai perjalanan: ' . $e->getMessage(), 500);
}

jsonSuccess(null, 'Perjalanan dimulai. Selamat bertugas!');
