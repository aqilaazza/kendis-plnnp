<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

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
// CEK KEGIATAN
// =========================================================

$stmt = $pdo->prepare(
    "SELECT id, id_driver
     FROM kegiatan_harian
     WHERE id = :id
     LIMIT 1"
);

$stmt->execute([
    'id' => $id,
]);

$kegiatan = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$kegiatan) {
    jsonError(
        'Kegiatan tidak ditemukan',
        404
    );
}

// =========================================================
// CEK APAKAH SUDAH DIAMBIL
// =========================================================

if (!empty($kegiatan['id_driver'])) {

    // Kalau kegiatan sudah diambil oleh driver lain
    if ((int) $kegiatan['id_driver'] !== (int) $user['id']) {
        jsonError(
            'Kegiatan ini sudah diambil oleh driver lain',
            409
        );
    }

    // Kalau ternyata sudah menjadi tugas driver sendiri
    jsonError(
        'Kegiatan ini sudah menjadi tugas Anda',
        409
    );
}

// =========================================================
// AMBIL KEGIATAN
// =========================================================

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

// =========================================================
// CEK HASIL UPDATE
// =========================================================

if ($stmt->rowCount() === 0) {
    jsonError(
        'Kegiatan gagal diambil atau sudah diambil driver lain',
        409
    );
}

// =========================================================
// NOTIFIKASI: kabari driver lain kalau kegiatan ini sudah diambil
// =========================================================

try {
    $stmtNotif = $pdo->prepare(
        "INSERT INTO notifikasi (id_user, kategori, tipe, judul, pesan, is_read, created_at)
         SELECT id, 'kegiatan', 'kegiatan_diambil_driver_lain',
                'Kegiatan Diambil Driver Lain',
                'Salah satu kegiatan harian telah diambil oleh driver lain.',
                0, NOW()
         FROM users
         WHERE role = 'driver'
           AND is_active = 1
           AND id != :uid"
    );
    $stmtNotif->execute([
        'uid' => $user['id'],
    ]);
} catch (\Throwable $e) {
    // Sengaja tidak menggagalkan proses ambil kegiatan kalau notifikasi gagal terkirim.
    @error_log('[NOTIF] Gagal insert notifikasi kegiatan_diambil_driver_lain: ' . $e->getMessage());
}

jsonSuccess(
    null,
    'Kegiatan berhasil Anda ambil'
);