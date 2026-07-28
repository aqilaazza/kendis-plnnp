<?php
require_once __DIR__ . '/../config/headers.php';
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
    if (empty($_FILES[$fieldName]) || $_FILES[$fieldName]['error'] === UPLOAD_ERR_NO_FILE) {
        return null;
    }
    if ($_FILES[$fieldName]['error'] !== UPLOAD_ERR_OK) {
        throw new Exception("Upload $fieldName gagal, kode error: " . $_FILES[$fieldName]['error']);
    }

    $uploadDir = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'uploads' . DIRECTORY_SEPARATOR;
    if (!is_dir($uploadDir)) {
        $mk = mkdir($uploadDir, 0777, true);
        if (!$mk && !is_dir($uploadDir)) {
            throw new Exception("Gagal membuat folder uploads: $uploadDir");
        }
    }
    if (!is_writable($uploadDir)) {
        throw new Exception("Folder uploads tidak writable: $uploadDir (cek permission/owner)");
    }

    $ext = pathinfo($_FILES[$fieldName]['name'], PATHINFO_EXTENSION);
    $filename = $fieldName . '_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
    $target = $uploadDir . $filename;

    if (!move_uploaded_file($_FILES[$fieldName]['tmp_name'], $target)) {
        throw new Exception("move_uploaded_file gagal untuk $fieldName ke $target");
    }
    return $filename;
}

try {
    $fotoBbm = handleUpload('foto_bbm');
    $fotoParkir = handleUpload('foto_parkir');
    $fotoTol = handleUpload('foto_tol');
} catch (Exception $e) {
    error_log('[SUBMIT UPLOAD ERROR] ' . $e->getMessage());
    jsonError('Gagal upload file: ' . $e->getMessage(), 500);
}

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
                . " WHERE id_penugasan = :id_penugasan";
    } else {
        $sql = "INSERT INTO laporan_driver
                    (id_penugasan, liter_bbm, rupiah_bbm, foto_bbm, rupiah_parkir, foto_parkir,
                     rupiah_tol, foto_tol, total_pelaporan, odo_start, odo_stop)
                VALUES
                    (:id_penugasan, :liter_bbm, :rupiah_bbm, :foto_bbm, :rupiah_parkir, :foto_parkir,
                     :rupiah_tol, :foto_tol, :total, :odo_start, :odo_stop)";
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

    if ($row) {
        // UPDATE: kolom foto cuma di-set kalau ada foto baru yang diupload
        if ($fotoBbm) $params['foto_bbm'] = $fotoBbm;
        if ($fotoParkir) $params['foto_parkir'] = $fotoParkir;
        if ($fotoTol) $params['foto_tol'] = $fotoTol;
    } else {
        // INSERT: butuh semua key foto walau null
        $params['foto_bbm'] = $fotoBbm;
        $params['foto_parkir'] = $fotoParkir;
        $params['foto_tol'] = $fotoTol;
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
    error_log('[SUBMIT DB ERROR] ' . $e->getMessage());
    jsonError('Gagal menyimpan laporan: ' . $e->getMessage(), 500);
}

jsonSuccess(null, 'Laporan berhasil disimpan');