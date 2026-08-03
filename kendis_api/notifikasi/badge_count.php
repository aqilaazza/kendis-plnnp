<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS jumlah FROM notifikasi WHERE id_user = :uid AND is_read = 0"
);
$stmt->execute(['uid' => $user['id']]);
$jumlah = (int) $stmt->fetch()['jumlah'];

jsonSuccess([
    'belum_dibaca' => $jumlah,
]);