<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';

$uploadDir = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'uploads' . DIRECTORY_SEPARATOR;

$info = [
    'upload_dir' => $uploadDir,
    'dir_exists' => is_dir($uploadDir),
    'dir_writable' => is_writable($uploadDir),
    'php_user' => getenv('USERNAME'),
    'upload_max_filesize' => ini_get('upload_max_filesize'),
    'post_max_size' => ini_get('post_max_size'),
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'unknown',
];

if (!is_dir($uploadDir)) {
    $mk = mkdir($uploadDir, 0777, true);
    $info['mkdir_result'] = $mk;
    $info['dir_exists_after'] = is_dir($uploadDir);
} else {
    $testFile = $uploadDir . 'test_' . time() . '.txt';
    $written = file_put_contents($testFile, 'ok');
    $info['write_test'] = $written !== false ? 'OK' : 'FAILED';
    if ($written !== false) unlink($testFile);
}

jsonSuccess($info);
