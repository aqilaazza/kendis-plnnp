<?php
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->prepare(
        "SELECT * FROM notifikasi WHERE id_user = :uid ORDER BY created_at DESC LIMIT 50"
    );
    $stmt->execute(['uid' => $user['id']]);
    jsonSuccess($stmt->fetchAll());
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Tandai satu notifikasi sudah dibaca: { "id": 12 }
    $body = getJsonBody();
    $id = $body['id'] ?? null;
    if (!$id) {
        jsonError('id wajib diisi', 422);
    }
    $stmt = $pdo->prepare("UPDATE notifikasi SET is_read = 1 WHERE id = :id AND id_user = :uid");
    $stmt->execute(['id' => $id, 'uid' => $user['id']]);
    jsonSuccess(null, 'Notifikasi ditandai sudah dibaca');
}

jsonError('Method tidak diizinkan', 405);
