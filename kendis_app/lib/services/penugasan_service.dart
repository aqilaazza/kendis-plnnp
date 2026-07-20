import '../core/api_client.dart';
import '../models/penugasan_model.dart';

class PenugasanService {
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await ApiClient.get('/profil/dashboard.php');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<PenugasanModel>> getList({String status = 'semua'}) async {
    final res = await ApiClient.get('/penugasan/list.php?status=$status');
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
}
