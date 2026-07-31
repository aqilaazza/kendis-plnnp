<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';

// NOTE: satu-satunya tempat yang perlu disesuaikan kalau lokasi folder
// uploads berubah (mis. pas pindah ke hosting produksi, atau kalau folder
// `kendis` & `kendis-plnnp` ternyata bukan sejajar di server produksi).
// File ini ada di kendis_api/penugasan/file.php, jadi perlu naik 3 folder
// (penugasan -> kendis_api -> kendis-plnnp -> www) baru masuk ke kendis/uploads.
// Idealnya folder uploads dipindah/di-symlink ke dalam project kendis_api
// sendiri (mis. jadi kendis_api/uploads) supaya baris ini tinggal:
//   $uploadsRoot = realpath(__DIR__ . '/../uploads');
$uploadsRoot = realpath(__DIR__ . '/../../../kendis/uploads');

$path = $_GET['path'] ?? '';
if ($path === '') {
    http_response_code(422);
    echo 'Parameter path wajib diisi';
    exit;
}

// Cegah directory traversal (../../../etc/passwd dsb).
$path = str_replace('\\', '/', $path);
if ($uploadsRoot === false || strpos($path, '..') !== false) {
    http_response_code(404);
    echo 'File tidak ditemukan';
    exit;
}

$fullPath = realpath($uploadsRoot . '/' . ltrim($path, '/'));

if ($fullPath === false || strpos($fullPath, $uploadsRoot) !== 0 || !is_file($fullPath)) {
    http_response_code(404);
    echo 'File tidak ditemukan';
    exit;
}

$mime = function_exists('mime_content_type') ? (mime_content_type($fullPath) ?: 'application/octet-stream') : 'application/octet-stream';
header('Content-Type: ' . $mime);
header('Content-Length: ' . filesize($fullPath));
header('Cache-Control: public, max-age=86400');
readfile($fullPath);