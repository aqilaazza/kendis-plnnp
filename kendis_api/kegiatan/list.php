<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// =========================================================
// GET - AMBIL SEMUA KEGIATAN
// =========================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $stmt = $pdo->prepare(
        "SELECT
            kh.id,
            kh.nama_kegiatan,
            kh.tujuan,
            kh.tanggal,
            kh.jam,
            kh.id_driver,
            d.nama AS nama_driver,
            d.nid AS nid_driver
        FROM kegiatan_harian kh
        LEFT JOIN users d
            ON kh.id_driver = d.id
        ORDER BY kh.tanggal DESC, kh.jam DESC"
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