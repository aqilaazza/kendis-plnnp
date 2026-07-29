import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<UserModel> login(String nid, String password) async {
    // TODO HAPUS - DEBUG
    const ep = '/auth/login.php';
    debugPrint('=== LOGIN REQUEST ===');
    debugPrint('Endpoint: $ep');
    debugPrint('Candidate URLs: ${AppConfig.candidateUrls}');
    debugPrint('Body keys: nid, password');

    Map<String, dynamic> res;
    try {
      res = await ApiClient.post(ep, {
        'nid': nid,
        'password': password,
      });
      // TODO HAPUS - DEBUG
      debugPrint('Login response status: true');
      debugPrint('Login response data keys: ${res.keys}');
    } catch (e) {
      // TODO HAPUS - DEBUG
      debugPrint('=== LOGIN ERROR ===');
      debugPrint('Exception type: ${e.runtimeType}');
      debugPrint('Exception toString: $e');
      if (e is ApiException) {
        debugPrint('ApiException statusCode: ${e.statusCode}');
        debugPrint('ApiException message: ${e.message}');
      }
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }

    final data = res['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_nama', user.nama);

    return user;
  }

  // ============================================================
  // GET PROFILE
  // ============================================================

  static Future<UserModel> getProfile() async {
    final res = await ApiClient.get('/profil/me.php');

    final data = res['data'] as Map<String, dynamic>;

    return UserModel.fromJson(data);
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  static Future<UserModel> updateProfile({
    required String noHp,
    required String noSim,
  }) async {
    await ApiClient.post('/profil/me.php', {
      'no_hp': noHp,
      'no_sim': noSim,
    });


    // API saat ini mengembalikan:
    // jsonSuccess(null, 'Profil berhasil diperbarui');
    // Jadi belum ada data user terbaru di response.
    // Untuk sementara kembalikan data dari API
    // setelah update melalui getProfile().

    return await getProfile();
  }

  // ============================================================
  // GANTI PASSWORD
  // ============================================================

  static Future<void> changePassword({
  required String passwordLama,
  required String passwordBaru,
  }) async {
    await ApiClient.post('/profil/change_password.php', {
      'password_lama': passwordLama,
      'password_baru': passwordBaru,
    });
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout.php', {});
    } catch (_) {
      // tetap hapus sesi lokal walau request gagal
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ============================================================
  // CEK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token') != null;
  }
}