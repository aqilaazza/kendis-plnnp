<?php
// Mengizinkan akses koneksi dari mana saja
header("Access-Control-Allow-Origin: *");

// Mengizinkan metode request yang dipakai oleh aplikasi Flutter
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");

// PENTING: Mengizinkan header khusus dari Flutter & Ngrok
header("Access-Control-Allow-Headers: Content-Type, Authorization, ngrok-skip-browser-warning");

// Menjawab otomatis "pertanyaan izin" (Preflight OPTIONS) dari browser Chrome
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>