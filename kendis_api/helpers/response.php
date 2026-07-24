<?php
require_once __DIR__ . '/../config/cors.php';

// Prevent error output in response body
ini_set('display_errors', '0');
error_reporting(E_ALL);

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

// --- Global Error & Exception Handlers ---
// Ensures API always returns JSON, never raw HTML errors

function jsonErrorHandler($severity, $message, $file, $line): bool {
    if (!(error_reporting() & $severity)) {
        return false;
    }
    throw new ErrorException($message, 0, $severity, $file, $line);
}

function jsonExceptionHandler($exception): void {
    jsonError('Internal Server Error', 500);
}

function jsonShutdownHandler(): void {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        http_response_code(500);
        echo json_encode(['status' => false, 'message' => 'Internal Server Error']);
        exit;
    }
}

set_error_handler('jsonErrorHandler');
set_exception_handler('jsonExceptionHandler');
register_shutdown_function('jsonShutdownHandler');
