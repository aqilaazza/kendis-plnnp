<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// =========================================================
// GET - AMBIL DATA KONTAK ADMIN (cuma 1 baris)
// =========================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $stmt = $pdo->prepare(
        "SELECT
            nama,
            nomor_whatsapp,
            pesan_default
        FROM kontak_admin
        ORDER BY id ASC
        LIMIT 1"
    );

    $stmt->execute();

    $kontak = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$kontak) {
        jsonError('Data kontak admin belum tersedia', 404);
    }

    jsonSuccess($kontak);
}

// =========================================================
// METHOD TIDAK DIIZINKAN
// =========================================================

jsonError(
    'Method tidak diizinkan',
    405
);