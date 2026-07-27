<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// ============================================================
// HANYA POST
// ============================================================

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {

    jsonError(
        'Method tidak diizinkan',
        405
    );
}

// ============================================================
// AMBIL DATA
// ============================================================

$body = getJsonBody();

$id = $body['id'] ?? null;

if (!$id) {

    jsonError(
        'ID kegiatan wajib diisi',
        422
    );
}

// ============================================================
// BATALKAN KEGIATAN
// HANYA DRIVER YANG MENGAMBIL YANG BOLEH MEMBATALKAN
// ============================================================

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

// ============================================================
// CEK HASIL
// ============================================================

if ($stmt->rowCount() === 0) {

    jsonError(
        'Kegiatan tidak ditemukan atau bukan tugas Anda',
        404
    );
}

// ============================================================
// RESPONSE
// ============================================================

jsonSuccess(
    [
        'id' => $id,
        'id_driver' => null,
    ],
    'Kegiatan berhasil dibatalkan'
);