<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// =========================================================
// GET - AMBIL PENGATURAN NOTIFIKASI DRIVER YANG LOGIN
// =========================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $stmt = $pdo->prepare(
        "SELECT
            notifikasi_penugasan,
            perubahan_status,
            informasi_pengumuman,
            suara_notifikasi
        FROM pengaturan_notifikasi
        WHERE id_user = :id_user"
    );

    $stmt->execute([
        'id_user' => $user['id'],
    ]);

    $pengaturan = $stmt->fetch(PDO::FETCH_ASSOC);

    // Kalau driver belum pernah simpan pengaturan (belum ada baris),
    // balikin default semua aktif tanpa perlu insert dulu ke database.
    if (!$pengaturan) {
        $pengaturan = [
            'notifikasi_penugasan' => 1,
            'perubahan_status' => 1,
            'informasi_pengumuman' => 1,
            'suara_notifikasi' => 1,
        ];
    }

    jsonSuccess([
        'notifikasi_penugasan' => (bool) $pengaturan['notifikasi_penugasan'],
        'perubahan_status' => (bool) $pengaturan['perubahan_status'],
        'informasi_pengumuman' => (bool) $pengaturan['informasi_pengumuman'],
        'suara_notifikasi' => (bool) $pengaturan['suara_notifikasi'],
    ]);
}

// =========================================================
// POST - SIMPAN / UPDATE PENGATURAN NOTIFIKASI
// =========================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $body = json_decode(file_get_contents('php://input'), true);

    if (!is_array($body)) {
        jsonError('Data tidak valid', 400);
    }

    // Field yang wajib ada di body request. Kalau salah satu gak dikirim,
    // dianggap error supaya driver gak sengaja nge-reset kolom lain jadi
    // NULL/kosong secara gak sengaja.
    $requiredFields = [
        'notifikasi_penugasan',
        'perubahan_status',
        'informasi_pengumuman',
        'suara_notifikasi',
    ];

    foreach ($requiredFields as $field) {
        if (!array_key_exists($field, $body)) {
            jsonError("Field '$field' wajib diisi", 400);
        }
    }

    // INSERT kalau driver belum punya baris, UPDATE kalau sudah ada —
    // dibedain lewat UNIQUE KEY (id_user) yang sudah di-set di tabel.
    $stmt = $pdo->prepare(
        "INSERT INTO pengaturan_notifikasi
            (id_user, notifikasi_penugasan, perubahan_status, informasi_pengumuman, suara_notifikasi)
        VALUES
            (:id_user, :notifikasi_penugasan, :perubahan_status, :informasi_pengumuman, :suara_notifikasi)
        ON DUPLICATE KEY UPDATE
            notifikasi_penugasan = VALUES(notifikasi_penugasan),
            perubahan_status = VALUES(perubahan_status),
            informasi_pengumuman = VALUES(informasi_pengumuman),
            suara_notifikasi = VALUES(suara_notifikasi)"
    );

    $stmt->execute([
        'id_user' => $user['id'],
        'notifikasi_penugasan' => $body['notifikasi_penugasan'] ? 1 : 0,
        'perubahan_status' => $body['perubahan_status'] ? 1 : 0,
        'informasi_pengumuman' => $body['informasi_pengumuman'] ? 1 : 0,
        'suara_notifikasi' => $body['suara_notifikasi'] ? 1 : 0,
    ]);

    jsonSuccess([
        'message' => 'Pengaturan notifikasi berhasil disimpan',
    ]);
}

// =========================================================
// METHOD TIDAK DIIZINKAN
// =========================================================

jsonError(
    'Method tidak diizinkan',
    405
);