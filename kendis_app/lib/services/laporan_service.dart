import 'package:image_picker/image_picker.dart';
import '../core/api_client.dart';

class LaporanService {
  static Future<void> submit({
    required int idPenugasan,
    double literBbm = 0,
    double rupiahBbm = 0,
    double rupiahParkir = 0,
    double rupiahTol = 0,
    int odoStart = 0,
    int odoStop = 0,
    XFile? fotoBbm,
    XFile? fotoParkir,
    XFile? fotoTol,
    XFile? fotoOdoStart,
    XFile? fotoOdoStop,
  }) async {
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
      {
        'foto_bbm': fotoBbm,
        'foto_parkir': fotoParkir,
        'foto_tol': fotoTol,
        'foto_odo_start': fotoOdoStart,
        'foto_odo_stop': fotoOdoStop,
      },
    );
  }
}