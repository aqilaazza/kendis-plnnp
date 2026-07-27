<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// ============================================================
// GET - LIST KEGIATAN
// SEMUA DRIVER BISA MELIHAT KEGIATAN
// ============================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $stmt = $pdo->prepare(
        "SELECT 
            id,
            nama_kegiatan,
            tujuan,
            tanggal,
            jam,
            id_driver
         FROM kegiatan_harian
         ORDER BY tanggal ASC, jam ASC"
    );

    $stmt->execute();

    jsonSuccess(
        $stmt->fetchAll()
    );
}


// ============================================================
// POST - PILIH / AMBIL KEGIATAN
// ============================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $body = getJsonBody();

    $id = $body['id'] ?? null;

    if (!$id) {
        jsonError(
            'ID kegiatan wajib diisi',
            422
        );
    }

    // ========================================================
    // CEK KEGIATAN
    // ========================================================

    $stmt = $pdo->prepare(
        "SELECT 
            id,
            id_driver
         FROM kegiatan_harian
         WHERE id = :id
         LIMIT 1"
    );

    $stmt->execute([
        'id' => $id,
    ]);

    $kegiatan = $stmt->fetch();

    if (!$kegiatan) {
        jsonError(
            'Kegiatan tidak ditemukan',
            404
        );
    }

    // ========================================================
    // CEK APAKAH SUDAH DIAMBIL DRIVER LAIN
    // ========================================================

    if (!empty($kegiatan['id_driver'])) {

        jsonError(
            'Kegiatan sudah diambil oleh driver lain',
            409
        );
    }

    // ========================================================
    // AMBIL KEGIATAN
    // ========================================================

    $stmt = $pdo->prepare(
        "UPDATE kegiatan_harian
         SET id_driver = :uid
         WHERE id = :id
           AND id_driver IS NULL"
    );

    $stmt->execute([
        'uid' => $user['id'],
        'id' => $id,
    ]);

    if ($stmt->rowCount() === 0) {

        jsonError(
            'Kegiatan gagal diambil atau sudah diambil driver lain',
            409
        );
    }

    jsonSuccess(
        [
            'id' => $id,
            'id_driver' => $user['id'],
        ],
        'Kegiatan berhasil diambil'
    );
}


// ============================================================
// METHOD TIDAK DIIZINKAN
// ============================================================

jsonError(
    'Method tidak diizinkan',
    405
);