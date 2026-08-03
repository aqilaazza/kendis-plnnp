import '../core/api_client.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  /// filter: 'semua' (default) | 'belum_dibaca' | 'riwayat' (sudah dibaca)
  static Future<List<NotifikasiModel>> getList({String filter = 'semua'}) async {
    final res = await ApiClient.get('/notifikasi/list.php?filter=$filter');
    final list = res['data'] as List;
    return list
        .map((e) => NotifikasiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Jumlah notifikasi yang belum dibaca — dipakai untuk badge di icon lonceng.
  static Future<int> getBadgeCount() async {
    final res = await ApiClient.get('/notifikasi/badge_count.php');
    final data = res['data'] as Map<String, dynamic>;
    return int.tryParse(data['belum_dibaca'].toString()) ?? 0;
  }

  /// Tandai satu notifikasi sudah dibaca.
  static Future<void> markRead(int id) async {
    await ApiClient.post('/notifikasi/mark_read.php', {'id': id});
  }

  /// Tandai semua notifikasi milik user ini sudah dibaca.
  static Future<void> markAllRead() async {
    await ApiClient.post('/notifikasi/mark_read.php', {'mark_all': true});
  }
}