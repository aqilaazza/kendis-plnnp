<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method tidak diizinkan', 405);
}

$headers = getallheaders();
$authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
$token = stripos($authHeader, 'Bearer ') === 0 ? trim(substr($authHeader, 7)) : null;

if ($token) {
    $pdo = getDbConnection();
    $stmt = $pdo->prepare("DELETE FROM auth_tokens WHERE token = :token");
    $stmt->execute(['token' => $token]);
}

jsonSuccess(null, 'Logout berhasil');
