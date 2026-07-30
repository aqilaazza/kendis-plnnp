import '../core/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  /// Menggabungkan data dari endpoint profil/dashboard.php dan
  /// dashboard/statistik.php menjadi satu [DashboardModel].
  static Future<DashboardModel> load() async {
    final dashRes = await ApiClient.get('/profil/dashboard.php');
    final dashData = dashRes['data'] as Map<String, dynamic>;
    
    // Melacak data dari profil
    print('=== JSON PROFIL ===');
    print(dashData);

    try {
      final ringkasanRes = await ApiClient.get('/penugasan/ringkasan.php?periode=bulan_ini');
      final ringkasanData = ringkasanRes['data'] as Map<String, dynamic>;
      
      // Melacak data dari ringkasan
      print('=== JSON RINGKASAN ===');
      print(ringkasanData);
      
      dashData.addAll(ringkasanData);
    } catch (e) {
      // Menampilkan error jika API ringkasan bermasalah
      print('=== ERROR API RINGKASAN ===');
      print(e.toString());
    }

    try {
      final statRes = await ApiClient.get('/dashboard/statistik.php');
      final statData = statRes['data'] as Map<String, dynamic>;
      
      // Melacak data dari statistik (Grafik, Donut Chart, Aktivitas)
      print('=== JSON STATISTIK ===');
      print(statData);
      
      dashData.addAll(statData);
    } catch (e) {
      // Menampilkan error jika API statistik bermasalah
      print('=== ERROR API STATISTIK ===');
      print(e.toString());
    }

    return DashboardModel.fromJson(dashData);
  }
}