<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method tidak diizinkan', 405);
}

// Body: { "id": 12 }              -> tandai 1 notifikasi sudah dibaca
// Body: { "mark_all": true }      -> tandai semua notifikasi (milik user ini) sudah dibaca
$body = getJsonBody();
$id = $body['id'] ?? null;
$markAll = $body['mark_all'] ?? false;

if ($markAll) {
    $stmt = $pdo->prepare(
        "UPDATE notifikasi
         SET is_read = 1, read_at = NOW()
         WHERE id_user = :uid AND is_read = 0"
    );
    $stmt->execute(['uid' => $user['id']]);
    jsonSuccess(null, 'Semua notifikasi ditandai sudah dibaca');
}

if (!$id) {
    jsonError('id wajib diisi', 422);
}

$stmt = $pdo->prepare(
    "UPDATE notifikasi
     SET is_read = 1, read_at = NOW()
     WHERE id = :id AND id_user = :uid"
);
$stmt->execute(['id' => $id, 'uid' => $user['id']]);

jsonSuccess(null, 'Notifikasi ditandai sudah dibaca');