import '../core/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  static Future<DriverDashboardModel> fetchDashboard() async {
    final res = await ApiClient.get('/driver/dashboard.php');
    return DriverDashboardModel.fromJson(res['data']);
  }
}
