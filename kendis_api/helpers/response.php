<?php
require_once __DIR__ . '/../config/cors.php';

ini_set('display_errors', '0');
error_reporting(E_ALL);

define('_JSON_FLAGS', JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_IGNORE);

function jsonSuccess($data = null, string $message = 'OK', int $code = 200): void {
    http_response_code($code);
    echo json_encode(['status' => true, 'message' => $message, 'data' => $data], _JSON_FLAGS);
    exit;
}

function jsonError(string $message = 'Terjadi kesalahan', int $code = 400, $data = null): void {
    http_response_code($code);
    echo json_encode(['status' => false, 'message' => $message, 'data' => $data], _JSON_FLAGS);
    exit;
}

function getJsonBody(): array {
    $raw = file_get_contents('php://input');
    $body = json_decode($raw, true);
    return is_array($body) ? $body : [];
}

function jsonErrorHandler($severity, $message, $file, $line): bool {
    if (!(error_reporting() & $severity)) {
        return false;
    }
    throw new ErrorException($message, 0, $severity, $file, $line);
}

function jsonExceptionHandler($exception): void {
    @error_log('[API ERROR] ' . $exception->getMessage() . ' in ' . $exception->getFile() . ':' . $exception->getLine());
    jsonError('DEBUG: ' . $exception->getMessage() . ' in ' . basename($exception->getFile()) . ' line ' . $exception->getLine(), 500);
}

function jsonShutdownHandler(): void {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        @error_log('[FATAL] ' . $error['message'] . ' in ' . $error['file'] . ':' . $error['line']);
        http_response_code(500);
        echo json_encode([
            'status' => false,
            'message' => 'DEBUG FATAL: ' . $error['message'] . ' in ' . basename($error['file']) . ' line ' . $error['line'],
        ], _JSON_FLAGS);
        exit;
    }
}

set_error_handler('jsonErrorHandler');
set_exception_handler('jsonExceptionHandler');
register_shutdown_function('jsonShutdownHandler');