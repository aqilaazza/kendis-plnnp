<?php
require_once __DIR__ . '/../config/cors.php';

function jsonSuccess($data = null, string $message = 'OK', int $code = 200): void {
    http_response_code($code);
    echo json_encode(['status' => true, 'message' => $message, 'data' => $data]);
    exit;
}

function jsonError(string $message = 'Terjadi kesalahan', int $code = 400, $data = null): void {
    http_response_code($code);
    echo json_encode(['status' => false, 'message' => $message, 'data' => $data]);
    exit;
}

function getJsonBody(): array {
    $raw = file_get_contents('php://input');
    $body = json_decode($raw, true);
    return is_array($body) ? $body : [];
}
