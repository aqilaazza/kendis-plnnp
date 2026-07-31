import '../core/api_client.dart';
import '../models/penugasan_model.dart';
import '../models/kendaraan_model.dart';

class PenugasanService {
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await ApiClient.get('/profil/dashboard.php');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<PenugasanModel>> getList({String status = 'semua', String search = ''}) async {
    var url = '/penugasan/list.php?status=$status';
    if (search.trim().isNotEmpty) {
      url += '&q=${Uri.encodeQueryComponent(search.trim())}';
    }
    final res = await ApiClient.get(url);
    final list = res['data'] as List;
    return list.map((e) => PenugasanModel.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> getDetail(int id) async {
    final res = await ApiClient.get('/penugasan/detail.php?id=$id');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<void> mulaiPerjalanan(int idPenugasan) async {
    await ApiClient.post('/penugasan/mulai.php', {'id_penugasan': idPenugasan});
  }

  static Future<Map<String, dynamic>> getRingkasan({String periode = 'bulan_ini'}) async {
    final res = await ApiClient.get('/penugasan/ringkasan.php?periode=$periode');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<KendaraanModel>> getKendaraanTersedia() async {
    final res = await ApiClient.get('/penugasan/kendaraan_tersedia.php');
    final list = res['data'] as List;
    return list.map((e) => KendaraanModel.fromJson(e)).toList();
  }

  /// Gabung "pilih kendaraan" + "mulai perjalanan" jadi satu aksi (sesuai
  /// alur penugasan terjadwal: driver pilih kendaraan lalu langsung jalan).
  static Future<void> pilihKendaraan({required int idPenugasan, required int idKendaraan}) async {
    await ApiClient.post('/penugasan/pilih_kendaraan.php', {
      'id_penugasan': idPenugasan,
      'id_kendaraan': idKendaraan,
    });
  }

  /// Jumlah tindakan yang masih pending (saat ini: penugasan yang sudah
  /// disetujui atasan pool tapi kendaraannya belum dipilih) — dipakai untuk
  /// badge di icon notifikasi.
  static Future<int> getPendingActionsCount() async {
    final res = await ApiClient.get('/penugasan/pending_actions_count.php');
    final data = res['data'] as Map<String, dynamic>;
    return int.tryParse(data['perlu_pilih_kendaraan'].toString()) ?? 0;
  }
}