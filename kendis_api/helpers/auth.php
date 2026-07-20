<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/response.php';

/**
 * Ambil token dari header Authorization: Bearer <token>
 * Validasi ke tabel auth_tokens, dan pastikan user-nya role driver.
 * Mengembalikan data user (array) jika valid, atau langsung return 401 jika tidak.
 */
function requireDriverAuth(): array {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (!$authHeader || stripos($authHeader, 'Bearer ') !== 0) {
        jsonError('Token tidak ditemukan. Silakan login kembali.', 401);
    }

    $token = trim(substr($authHeader, 7));
    $pdo = getDbConnection();

    $stmt = $pdo->prepare(
        "SELECT u.* FROM auth_tokens t
         JOIN users u ON u.id = t.user_id
         WHERE t.token = :token
           AND (t.expires_at IS NULL OR t.expires_at > NOW())
         LIMIT 1"
    );
    $stmt->execute(['token' => $token]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonError('Sesi tidak valid atau sudah kedaluwarsa. Silakan login kembali.', 401);
    }

    if ($user['role'] !== 'driver') {
        jsonError('Akses ditolak. Akun ini bukan akun driver.', 403);
    }

    if ((int)$user['is_active'] !== 1) {
        jsonError('Akun Anda nonaktif. Hubungi admin.', 403);
    }

    unset($user['password']);
    return $user;
}

function generateToken(): string {
    return bin2hex(random_bytes(32));
}
