<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// ============================================================
// AMBIL ID KEGIATAN
// ============================================================

$id = $_GET['id'] ?? null;

if (!$id) {
    jsonError('Parameter id wajib diisi', 422);
}

// ============================================================
// AMBIL DETAIL KEGIATAN
// SEMUA DRIVER YANG LOGIN DAPAT MELIHAT DETAIL
// ============================================================

$stmt = $pdo->prepare(
    "SELECT 
        id,
        nama_kegiatan,
        tujuan,
        tanggal,
        jam,
        id_driver
     FROM kegiatan_harian
     WHERE id = :id
     LIMIT 1"
);

$stmt->execute([
    'id' => $id,
]);

$kegiatan = $stmt->fetch();

// ============================================================
// JIKA TIDAK DITEMUKAN
// ============================================================

if (!$kegiatan) {
    jsonError('Kegiatan tidak ditemukan', 404);
}

// ============================================================
// RESPONSE
// ============================================================

jsonSuccess($kegiatan);