<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();

// =========================================================
// HANYA POST
// =========================================================

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError(
        'Method tidak diizinkan',
        405
    );
}

// =========================================================
// AMBIL DATA REQUEST
// =========================================================

$body = getJsonBody();

$id = (int) ($body['id'] ?? 0);

if ($id <= 0) {
    jsonError(
        'ID kegiatan tidak valid',
        422
    );
}

// =========================================================
// BATALKAN PENGAMBILAN
// =========================================================

$pdo = getDbConnection();

$stmt = $pdo->prepare(
    "UPDATE kegiatan_harian
     SET id_driver = NULL
     WHERE id = :id
       AND id_driver = :uid"
);

$stmt->execute([
    'id' => $id,
    'uid' => $user['id'],
]);

// =========================================================
// CEK HASIL
// =========================================================

if ($stmt->rowCount() === 0) {
    jsonError(
        'Kegiatan tidak ditemukan atau bukan tugas Anda',
        403
    );
}

jsonSuccess(
    null,
    'Pengambilan kegiatan berhasil dibatalkan'
);