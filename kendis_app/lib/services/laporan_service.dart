import 'dart:typed_data';
import '../core/api_client.dart';
import '../models/laporan_detail_model.dart';

class LaporanService {
  static Future<void> submit({
    required int idPenugasan,
    double literBbm = 0,
    double rupiahBbm = 0,
    double rupiahParkir = 0,
    double rupiahTol = 0,
    int odoStart = 0,
    int odoStop = 0,
    Uint8List? fotoBbmBytes,
    String? fotoBbmName,
    Uint8List? fotoParkirBytes,
    String? fotoParkirName,
    Uint8List? fotoTolBytes,
    String? fotoTolName,
  }) async {
    final files = <String, ({Uint8List bytes, String name})>{};
    if (fotoBbmBytes != null && fotoBbmName != null) files['foto_bbm'] = (bytes: fotoBbmBytes, name: fotoBbmName);
    if (fotoParkirBytes != null && fotoParkirName != null) files['foto_parkir'] = (bytes: fotoParkirBytes, name: fotoParkirName);
    if (fotoTolBytes != null && fotoTolName != null) files['foto_tol'] = (bytes: fotoTolBytes, name: fotoTolName);

    await ApiClient.postMultipart(
      '/laporan/submit.php',
      {
        'id_penugasan': idPenugasan.toString(),
        'liter_bbm': literBbm.toString(),
        'rupiah_bbm': rupiahBbm.toString(),
        'rupiah_parkir': rupiahParkir.toString(),
        'rupiah_tol': rupiahTol.toString(),
        'odo_start': odoStart.toString(),
        'odo_stop': odoStop.toString(),
      },
      files,
    );
  }

  /// Ambil detail laporan yang SUDAH dikirim driver untuk satu penugasan.
  /// Dipakai di DetailLaporanScreen (dibuka dari kartu Riwayat).
  static Future<LaporanDetailModel> getDetail(int idPenugasan) async {
    final res = await ApiClient.get('/laporan/detail.php?id_penugasan=$idPenugasan');
    return LaporanDetailModel.fromJson(res['data']);
  }
}