<?php

// Izinkan semua origin (untuk development)
header("Access-Control-Allow-Origin: *");

// Method yang diizinkan
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

// Header yang diizinkan
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization, Ngrok-Skip-Browser-Warning");

// Pastikan response selalu JSON
header("Content-Type: application/json; charset=utf-8");

// Tangani preflight request (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}