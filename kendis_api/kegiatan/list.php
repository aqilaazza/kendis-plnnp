<?php
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->prepare(
        "SELECT * FROM kegiatan_harian WHERE id_driver = :uid ORDER BY tanggal DESC, jam DESC"
    );
    $stmt->execute(['uid' => $user['id']]);
    jsonSuccess($stmt->fetchAll());
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = getJsonBody();
    $nama = trim($body['nama_kegiatan'] ?? '');
    $tujuan = trim($body['tujuan'] ?? '');
    $tanggal = $body['tanggal'] ?? null;
    $jam = $body['jam'] ?? null;

    if (!$nama || !$tujuan || !$tanggal || !$jam) {
        jsonError('nama_kegiatan, tujuan, tanggal, dan jam wajib diisi', 422);
    }

    $stmt = $pdo->prepare(
        "INSERT INTO kegiatan_harian (nama_kegiatan, tujuan, tanggal, jam, id_driver)
         VALUES (:nama, :tujuan, :tanggal, :jam, :uid)"
    );
    $stmt->execute([
        'nama' => $nama, 'tujuan' => $tujuan, 'tanggal' => $tanggal,
        'jam' => $jam, 'uid' => $user['id'],
    ]);

    jsonSuccess(['id' => $pdo->lastInsertId()], 'Kegiatan berhasil dicatat', 201);
}

jsonError('Method tidak diizinkan', 405);
