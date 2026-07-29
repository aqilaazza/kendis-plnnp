import '../core/api_client.dart';
import '../models/dashboard_model.dart';
import 'penugasan_service.dart';

class DashboardService {
  static Future<DashboardModel> load() async {
    final dashRes = await ApiClient.get('/profil/dashboard.php');
    final dashData = dashRes['data'] as Map<String, dynamic>;

    try {
      final ringkasanData = await PenugasanService.getRingkasan();
      dashData.addAll(ringkasanData);
    } catch (_) {}

    try {
      final statRes = await ApiClient.get('/dashboard/statistik.php');
      final statData = statRes['data'] as Map<String, dynamic>;
      dashData.addAll(statData);
    } catch (_) {}

    return DashboardModel.fromJson(dashData);
  }
}