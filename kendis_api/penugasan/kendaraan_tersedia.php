<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

requireDriverAuth();
$pdo = getDbConnection();

$stmt = $pdo->query(
    "SELECT id, nopol, merk, warna, foto
     FROM kendaraan
     WHERE status = 'tersedia'
     ORDER BY nopol ASC"
);
$list = $stmt->fetchAll();

jsonSuccess($list);