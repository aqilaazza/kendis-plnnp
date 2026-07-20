import '../core/api_client.dart';
import '../models/kegiatan_model.dart';

class KegiatanService {
  static Future<List<KegiatanModel>> getList() async {
    final res = await ApiClient.get('/kegiatan/list.php');
    final list = res['data'] as List;
    return list.map((e) => KegiatanModel.fromJson(e)).toList();
  }

  static Future<void> tambah({
    required String namaKegiatan,
    required String tujuan,
    required String tanggal,
    required String jam,
  }) async {
    await ApiClient.post('/kegiatan/list.php', {
      'nama_kegiatan': namaKegiatan,
      'tujuan': tujuan,
      'tanggal': tanggal,
      'jam': jam,
    });
  }
}

class NotifikasiService {
  static Future<List<NotifikasiModel>> getList() async {
    final res = await ApiClient.get('/notifikasi/list.php');
    final list = res['data'] as List;
    return list.map((e) => NotifikasiModel.fromJson(e)).toList();
  }

  static Future<void> tandaiDibaca(int id) async {
    await ApiClient.post('/notifikasi/list.php', {'id': id});
  }
}
