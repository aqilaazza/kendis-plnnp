<?php
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method tidak diizinkan', 405);
}

$body = getJsonBody();

$passwordLama = $body['password_lama'] ?? '';
$passwordBaru = $body['password_baru'] ?? '';

/*
|--------------------------------------------------------------------------
| VALIDASI INPUT
|--------------------------------------------------------------------------
*/

if ($passwordLama === '' || $passwordBaru === '') {
    jsonError('Password lama dan password baru wajib diisi', 422);
}

if (strlen($passwordBaru) < 6) {
    jsonError('Password baru minimal 6 karakter', 422);
}

/*
|--------------------------------------------------------------------------
| AMBIL PASSWORD USER SAAT INI
|--------------------------------------------------------------------------
*/

$stmt = $pdo->prepare(
    "SELECT password FROM users WHERE id = :id LIMIT 1"
);

$stmt->execute([
    'id' => $user['id'],
]);

$userData = $stmt->fetch();

if (!$userData) {
    jsonError('Data pengguna tidak ditemukan', 404);
}

/*
|--------------------------------------------------------------------------
| CEK PASSWORD LAMA
|--------------------------------------------------------------------------
*/

if (!password_verify($passwordLama, $userData['password'])) {
    jsonError('Password lama tidak sesuai', 401);
}

/*
|--------------------------------------------------------------------------
| CEK PASSWORD BARU TIDAK SAMA DENGAN PASSWORD LAMA
|--------------------------------------------------------------------------
*/

if (password_verify($passwordBaru, $userData['password'])) {
    jsonError(
        'Password baru tidak boleh sama dengan password lama',
        422
    );
}

/*
|--------------------------------------------------------------------------
| HASH PASSWORD BARU
|--------------------------------------------------------------------------
*/

$passwordHash = password_hash(
    $passwordBaru,
    PASSWORD_DEFAULT
);

/*
|--------------------------------------------------------------------------
| UPDATE PASSWORD
|--------------------------------------------------------------------------
*/

$stmtUpdate = $pdo->prepare(
    "UPDATE users
     SET password = :password
     WHERE id = :id"
);

$stmtUpdate->execute([
    'password' => $passwordHash,
    'id' => $user['id'],
]);

jsonSuccess(
    null,
    'Password berhasil diperbarui'
);