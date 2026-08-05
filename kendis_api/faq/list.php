<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// =========================================================
// GET - AMBIL DAFTAR FAQ (yang aktif saja, urut sesuai kolom urutan)
// =========================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $stmt = $pdo->prepare(
        "SELECT
            id,
            pertanyaan,
            jawaban
        FROM faq
        ORDER BY urutan ASC, id ASC"
    );

    $stmt->execute();

    jsonSuccess(
        $stmt->fetchAll(PDO::FETCH_ASSOC)
    );
}

// =========================================================
// METHOD TIDAK DIIZINKAN
// =========================================================

jsonError(
    'Method tidak diizinkan',
    405
);