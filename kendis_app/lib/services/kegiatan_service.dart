import '../core/api_client.dart';
import '../models/kegiatan_model.dart';

class KegiatanService {
  // ============================================================
  // LIST KEGIATAN
  // ============================================================

  static Future<List<KegiatanModel>> getList() async {
    final res = await ApiClient.get(
      '/kegiatan/list.php',
    );

    final list = res['data'] as List;

    return list
        .map(
          (e) => KegiatanModel.fromJson(e),
        )
        .toList();
  }

  // ============================================================
  // DETAIL KEGIATAN
  // ============================================================

  static Future<KegiatanModel> getDetail(
    int id,
  ) async {
    final res = await ApiClient.get(
      '/kegiatan/detail.php?id=$id',
    );

    return KegiatanModel.fromJson(
      res['data'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // AMBIL / PILIH KEGIATAN
  // ============================================================

  static Future<void> ambilKegiatan(
    int id,
  ) async {
    await ApiClient.post(
      '/kegiatan/list.php',
      {
        'id': id,
      },
    );
  }

  // ============================================================
  // BATALKAN KEGIATAN
  // ============================================================

  static Future<void> batalkanKegiatan(
    int id,
  ) async {
    await ApiClient.post(
      '/kegiatan/batalkan.php',
      {
        'id': id,
      },
    );
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
