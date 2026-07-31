import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  /// Menggabungkan data dari endpoint profil/dashboard.php dan
  /// dashboard/statistik.php menjadi satu [DashboardModel].
  static Future<DashboardModel> load() async {
    final dashRes = await ApiClient.get('/profil/dashboard.php');
    final dashData = dashRes['data'] as Map<String, dynamic>;
    
    // Melacak data dari profil
    debugPrint('=== JSON PROFIL ===');
    debugPrint(dashData.toString());

    try {
      final ringkasanRes = await ApiClient.get('/penugasan/ringkasan.php?periode=bulan_ini');
      final ringkasanData = ringkasanRes['data'] as Map<String, dynamic>;
      
      // Melacak data dari ringkasan
      debugPrint('=== JSON RINGKASAN ===');
      debugPrint(ringkasanData.toString());
      
      dashData.addAll(ringkasanData);
    } catch (e) {
      // Menampilkan error jika API ringkasan bermasalah
      debugPrint('=== ERROR API RINGKASAN ===');
      debugPrint(e.toString());
    }

    try {
      final statRes = await ApiClient.get('/dashboard/statistik.php');
      final statData = statRes['data'] as Map<String, dynamic>;
      
      // Melacak data dari statistik (Grafik, Donut Chart, Aktivitas)
      debugPrint('=== JSON STATISTIK ===');
      debugPrint(statData.toString());
      
      dashData.addAll(statData);
    } catch (e) {
      // Menampilkan error jika API statistik bermasalah
      debugPrint('=== ERROR API STATISTIK ===');
      debugPrint(e.toString());
    }

    return DashboardModel.fromJson(dashData);
  }
}
