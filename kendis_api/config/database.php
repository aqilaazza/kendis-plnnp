<?php
// Konfigurasi koneksi database untuk Laragon (MySQL/MariaDB)
// Sesuaikan jika kredensial Laragon-mu berbeda dari default

define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'kendis_upptn');
define('DB_USER', 'root');
define('DB_PASS', '');       // default Laragon: password kosong
define('DB_PORT', '3306');

function getDbConnection(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
            $pdo = new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Koneksi database gagal: ' . $e->getMessage()]);
            exit;
        }
    }
    return $pdo;
}
