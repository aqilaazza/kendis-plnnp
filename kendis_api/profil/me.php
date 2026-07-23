<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    jsonSuccess($user);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = getJsonBody();
    $noHp = trim($body['no_hp'] ?? $user['no_hp']);
    $noSim = trim($body['no_sim'] ?? $user['no_sim']);

    $stmt = $pdo->prepare("UPDATE users SET no_hp = :no_hp, no_sim = :no_sim WHERE id = :id");
    $stmt->execute(['no_hp' => $noHp, 'no_sim' => $noSim, 'id' => $user['id']]);

    jsonSuccess(null, 'Profil berhasil diperbarui');
}

jsonError('Method tidak diizinkan', 405);
