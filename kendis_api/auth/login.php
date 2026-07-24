<?php

require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/token_helper.php';

if (!function_exists('generateToken')) {
    jsonError('generateToken() tidak tersedia', 500, [
        'login_file' => __FILE__,
        'token_helper_path' => realpath(__DIR__ . '/../helpers/token_helper.php'),
        'token_helper_exists' => file_exists(__DIR__ . '/../helpers/token_helper.php'),
        'included_files' => get_included_files(),
    ]);
}

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    jsonError('Method tidak diizinkan', 405);
}

$body = getJsonBody();

$nid = trim($body['nid'] ?? '');
$password = $body['password'] ?? '';

if ($nid === '' || $password === '') {
    jsonError('NID/Username dan password wajib diisi', 422);
}

$pdo = getDbConnection();

$stmt = $pdo->prepare("
    SELECT *
    FROM users
    WHERE nid = :nid
    LIMIT 1
");

$stmt->execute([
    'nid' => $nid
]);

$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    jsonError('NID atau password salah', 401);
}

if (!password_verify($password, $user['password'])) {
    jsonError('NID atau password salah', 401);
}

if (($user['role'] ?? '') !== 'driver') {
    jsonError('Akun ini bukan akun driver.', 403);
}

if ((int)($user['is_active'] ?? 0) !== 1) {
    jsonError('Akun Anda nonaktif.', 403);
}

$token = generateToken();

$expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

$insert = $pdo->prepare("
    INSERT INTO auth_tokens
    (user_id, token, device_info, expires_at)
    VALUES
    (:uid,:token,:device,:exp)
");

$insert->execute([
    'uid' => $user['id'],
    'token' => $token,
    'device' => $body['device_info'] ?? '',
    'exp' => $expiresAt,
]);

unset($user['password']);

jsonSuccess([
    'token' => $token,
    'user' => $user,
], 'Login berhasil');