<?php
// Header standar untuk semua endpoint (dipanggil di awal setiap file endpoint)

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

function jsonSuccess($data = null, string $message = 'OK', int $code = 200): void {
    http_response_code($code);
    echo json_encode(['success' => true, 'message' => $message, 'data' => $data]);
    exit;
}

function jsonError(string $message = 'Terjadi kesalahan', int $code = 400, $data = null): void {
    http_response_code($code);
    echo json_encode(['success' => false, 'message' => $message, 'data' => $data]);
    exit;
}

function getJsonBody(): array {
    $raw = file_get_contents('php://input');
    $body = json_decode($raw, true);
    return is_array($body) ? $body : [];
}
