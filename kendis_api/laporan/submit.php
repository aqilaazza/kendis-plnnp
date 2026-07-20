<?php
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Method tidak diizinkan', 405);
}

$user = requireDriverAuth();
$pdo = getDbConnection();

// multipart/form-data: field teks di $_POST, file di $_FILES
$idPenugasan = $_POST['id_penugasan'] ?? null;
if (!$idPenugasan) {
    jsonError('id_penugasan wajib diisi', 422);
}

$check = $pdo->prepare("SELECT * FROM penugasan WHERE id = :id AND id_driver = :uid LIMIT 1");
$check->execute(['id' => $idPenugasan, 'uid' => $user['id']]);
$penugasan = $check->fetch();
if (!$penugasan) {
    jsonError('Penugasan tidak ditemukan', 404);
}

function handleUpload(string $fieldName): ?string {
    if (empty($_FILES[$fieldName]) || $_FILES[$fieldName]['error'] !== UPLOAD_ERR_OK) {
        return null;
    }
    $uploadDir = __DIR__ . '/../uploads/';
    $ext = pathinfo($_FILES[$fieldName]['name'], PATHINFO_EXTENSION);
    $filename = $fieldName . '_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
    $target = $uploadDir . $filename;
    if (move_uploaded_file($_FILES[$fieldName]['tmp_name'], $target)) {
        return $filename;
    }
    return null;
}

$fotoBbm = handleUpload('foto_bbm');
$fotoParkir = handleUpload('foto_parkir');
$fotoTol = handleUpload('foto_tol');
$fotoOdoStart = handleUpload('foto_odo_start');
$fotoOdoStop = handleUpload('foto_odo_stop');

$literBbm = (float)($_POST['liter_bbm'] ?? 0);
$rupiahBbm = (float)($_POST['rupiah_bbm'] ?? 0);
$rupiahParkir = (float)($_POST['rupiah_parkir'] ?? 0);
$rupiahTol = (float)($_POST['rupiah_tol'] ?? 0);
$odoStart = (int)($_POST['odo_start'] ?? 0);
$odoStop = (int)($_POST['odo_stop'] ?? 0);
$total = $rupiahBbm + $rupiahParkir + $rupiahTol;

$pdo->beginTransaction();
try {
    // Cek apakah laporan sudah ada -> update, kalau belum -> insert
    $existing = $pdo->prepare("SELECT id FROM laporan_driver WHERE id_penugasan = :id");
    $existing->execute(['id' => $idPenugasan]);
    $row = $existing->fetch();

    if ($row) {
        $sql = "UPDATE laporan_driver SET
                    liter_bbm = :liter_bbm, rupiah_bbm = :rupiah_bbm,
                    rupiah_parkir = :rupiah_parkir, rupiah_tol = :rupiah_tol,
                    total_pelaporan = :total, odo_start = :odo_start, odo_stop = :odo_stop"
                . ($fotoBbm ? ", foto_bbm = :foto_bbm" : "")
                . ($fotoParkir ? ", foto_parkir = :foto_parkir" : "")
                . ($fotoTol ? ", foto_tol = :foto_tol" : "")
                . ($fotoOdoStart ? ", foto_odo_start = :foto_odo_start" : "")
                . ($fotoOdoStop ? ", foto_odo_stop = :foto_odo_stop" : "")
                . " WHERE id_penugasan = :id_penugasan";
    } else {
        $sql = "INSERT INTO laporan_driver
                    (id_penugasan, liter_bbm, rupiah_bbm, foto_bbm, rupiah_parkir, foto_parkir,
                     rupiah_tol, foto_tol, total_pelaporan, odo_start, foto_odo_start, odo_stop, foto_odo_stop)
                VALUES
                    (:id_penugasan, :liter_bbm, :rupiah_bbm, :foto_bbm, :rupiah_parkir, :foto_parkir,
                     :rupiah_tol, :foto_tol, :total, :odo_start, :foto_odo_start, :odo_stop, :foto_odo_stop)";
    }

    $params = [
        'id_penugasan' => $idPenugasan,
        'liter_bbm' => $literBbm,
        'rupiah_bbm' => $rupiahBbm,
        'rupiah_parkir' => $rupiahParkir,
        'rupiah_tol' => $rupiahTol,
        'total' => $total,
        'odo_start' => $odoStart,
        'odo_stop' => $odoStop,
    ];
    if ($fotoBbm) $params['foto_bbm'] = $fotoBbm;
    if ($fotoParkir) $params['foto_parkir'] = $fotoParkir;
    if ($fotoTol) $params['foto_tol'] = $fotoTol;
    if ($fotoOdoStart) $params['foto_odo_start'] = $fotoOdoStart;
    if ($fotoOdoStop) $params['foto_odo_stop'] = $fotoOdoStop;
    if (!$row) {
        // insert butuh semua key foto walau null
        $params['foto_bbm'] = $fotoBbm;
        $params['foto_parkir'] = $fotoParkir;
        $params['foto_tol'] = $fotoTol;
        $params['foto_odo_start'] = $fotoOdoStart;
        $params['foto_odo_stop'] = $fotoOdoStop;
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);

    // Jika odo_stop diisi, anggap perjalanan selesai -> update status request
    if ($odoStop > 0) {
        $reqStmt = $pdo->prepare(
            "UPDATE request_kendis SET status = 'completed'
             WHERE id = (SELECT id_request FROM penugasan WHERE id = :id)"
        );
        $reqStmt->execute(['id' => $idPenugasan]);

        $reqInfo = $pdo->prepare(
            "SELECT r.id_pemohon, r.kode_request FROM request_kendis r
             JOIN penugasan p ON p.id_request = r.id WHERE p.id = :id"
        );
        $reqInfo->execute(['id' => $idPenugasan]);
        $ri = $reqInfo->fetch();

        $pdo->prepare(
            "INSERT INTO notifikasi (id_user, id_request, judul, pesan, link)
             VALUES (:uid, :rid, 'Perjalanan Selesai - Berikan Penilaian', :pesan, '/kendis/permintaan_saya.php')"
        )->execute([
            'uid' => $ri['id_pemohon'],
            'rid' => $penugasan['id_request'],
            'pesan' => "Perjalanan dinas {$ri['kode_request']} telah selesai. Silakan berikan rating untuk driver Anda.",
        ]);
    }

    $pdo->commit();
} catch (Exception $e) {
    $pdo->rollBack();
    jsonError('Gagal menyimpan laporan: ' . $e->getMessage(), 500);
}

jsonSuccess(null, 'Laporan berhasil disimpan');
