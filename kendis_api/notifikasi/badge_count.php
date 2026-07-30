<?php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

$user = requireDriverAuth();
$pdo = getDbConnection();

// =========================================================
// 1) TUGAS BELUM DIJALANKAN
// =========================================================
$stmtTugas = $pdo->prepare(
    "SELECT COUNT(*) AS jumlah
     FROM penugasan p
     JOIN request_kendis r ON r.id = p.id_request
     WHERE p.id_driver = :uid
       AND p.status_validasi_atasan_pool = 'approved'
       AND p.is_berangkat = 0
       AND r.status NOT IN ('completed', 'rated', 'cancelled')"
);
$stmtTugas->execute(['uid' => $user['id']]);
$tugasBelumDijalankan = (int) $stmtTugas->fetch()['jumlah'];

// =========================================================
// 2) KEGIATAN BELUM DIPILIH
// =========================================================
$stmtKegiatan = $pdo->prepare(
    "SELECT COUNT(*) AS jumlah
     FROM kegiatan_harian
     WHERE id_driver IS NULL"
);
$stmtKegiatan->execute();
$kegiatanBelumDipilih = (int) $stmtKegiatan->fetch()['jumlah'];

// =========================================================
// 3) LAPORAN BELUM DIISI
// =========================================================
$stmtLaporan = $pdo->prepare(
    "SELECT COUNT(*) AS jumlah
     FROM penugasan p
     LEFT JOIN laporan_driver ld ON ld.id_penugasan = p.id
     WHERE p.id_driver = :uid
       AND p.is_berangkat = 1
       AND (ld.id IS NULL OR ld.odo_stop IS NULL)"
);
$stmtLaporan->execute(['uid' => $user['id']]);
$laporanBelumDiisi = (int) $stmtLaporan->fetch()['jumlah'];

jsonSuccess([
    'tugas_belum_dijalankan'   => $tugasBelumDijalankan,
    'kegiatan_belum_dipilih'   => $kegiatanBelumDipilih,
    'laporan_belum_diisi'      => $laporanBelumDiisi,
]);