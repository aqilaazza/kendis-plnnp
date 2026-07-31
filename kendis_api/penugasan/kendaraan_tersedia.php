<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

requireDriverAuth();
$pdo = getDbConnection();

$stmt = $pdo->query(
    "SELECT id, nopol, merk, warna, foto, status
     FROM kendaraan
     ORDER BY nopol ASC"
);
$list = $stmt->fetchAll();

jsonSuccess($list);