<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/cron_reminder.php'; // definisi broadcastKegiatanBaru()

$user = requireDriverAuth();
$pdo = getDbConnection();

// Pastikan kegiatan baru yang belum sempat dinotifikasi (mis. oleh cron)
// langsung masuk daftar lonceng saat driver membukanya. Idempotent.
broadcastKegiatanBaru($pdo);

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Method tidak diizinkan', 405);
}

// filter: semua (default) | belum_dibaca | riwayat
$filter = $_GET['filter'] ?? 'semua';

$where = "WHERE id_user = :uid";
if ($filter === 'belum_dibaca') {
    $where .= " AND is_read = 0";
} elseif ($filter === 'riwayat') {
    $where .= " AND is_read = 1";
}
// 'semua' -> tidak menambah kondisi tambahan

$stmt = $pdo->prepare(
    "SELECT id, kategori, tipe, judul, pesan, id_request, id_kegiatan, is_read, created_at
     FROM notifikasi
     $where
     ORDER BY created_at DESC
     LIMIT 100"
);
$stmt->execute(['uid' => $user['id']]);

jsonSuccess($stmt->fetchAll());