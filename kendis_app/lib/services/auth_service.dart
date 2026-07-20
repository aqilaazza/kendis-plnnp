import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<UserModel> login(String nid, String password) async {
    final res = await ApiClient.post('/auth/login.php', {
      'nid': nid,
      'password': password,
    });

    final data = res['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_nama', user.nama);

    return user;
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout.php', {});
    } catch (_) {
      // tetap hapus sesi lokal walau request gagal (mis. tidak ada koneksi)
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}
