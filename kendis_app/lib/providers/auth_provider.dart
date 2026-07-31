import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, loggedIn, loggedOut }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? errorMessage;

  /// true jika error yang terjadi disebabkan oleh server/koneksi
  /// (bukan karena username/password salah). Dipakai di UI untuk
  /// menampilkan opsi "Hubungi Admin".
  bool isServerError = false;

  bool isLoading = false;

  /// Dipanggil sekali saat app start (lihat main.dart). Mengecek apakah
  /// ada sesi tersimpan, dan jika ada, langsung ambil data profil user
  /// sekalian sebelum status diubah menjadi loggedIn. Dengan begitu,
  /// begitu SplashGate pindah ke MainNavScreen, currentUser sudah pasti
  /// terisi (tidak ada momen menampilkan data kosong / '-').
  Future<void> checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();

    if (!loggedIn) {
      status = AuthStatus.loggedOut;
      notifyListeners();
      return;
    }

    // Token ada, tapi pastikan masih valid & ambil data user-nya sekalian
    try {
      await loadProfile();
      status = AuthStatus.loggedIn;
    } catch (_) {
      // Token expired / server error saat startup → anggap logged out
      currentUser = null;
      status = AuthStatus.loggedOut;
    }

    notifyListeners();
  }

  Future<bool> login(
    String nid,
    String password,
  ) async {
    isLoading = true;
    errorMessage = null;
    isServerError = false;
    notifyListeners();

    try {
      final user = await AuthService.login(
        nid,
        password,
      );

      currentUser = user;
      status = AuthStatus.loggedIn;
      isLoading = false;

      notifyListeners();

      return true;
    } catch (e) {
      _setErrorFromException(e);

      isLoading = false;

      notifyListeners();

      return false;
    }
  }

  /// Menentukan pesan error & apakah ini masalah server/koneksi
  /// atau memang username/password yang salah.
  void _setErrorFromException(Object e) {
    if (e is ApiException) {
      final statusCode = e.statusCode;

      if (statusCode == 401) {
        // Kredensial salah
        errorMessage = 'Username atau password yang Anda masukkan salah.';
        isServerError = false;
      } else if (statusCode == null || statusCode >= 500) {
        // Gagal konek ke semua kandidat URL, atau server error internal
        errorMessage =
            'Server sedang bermasalah. Silakan coba lagi beberapa saat, atau hubungi admin jika masalah berlanjut.';
        isServerError = true;
      } else {
        // Error lain dari API (validasi, dsb) — tampilkan apa adanya
        errorMessage = e.message;
        isServerError = false;
      }
    } else {
      // Exception di luar ApiException (misal SocketException, dsb)
      errorMessage =
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau hubungi admin.';
      isServerError = true;
    }
  }

  // ============================================================
  // LOAD / REFRESH PROFILE
  // ============================================================

  /// Ambil data profil terbaru dari server (GET /profil/me.php) dan
  /// simpan ke currentUser. Exception dilempar lagi ke pemanggil (mis.
  /// ProfilScreen atau checkLoginStatus) supaya pemanggil yang menentukan
  /// tampilan/penanganan error-nya.
  Future<void> loadProfile() async {
    final user = await AuthService.getProfile();

    currentUser = user;
    notifyListeners();
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<bool> updateProfile({
    required String noHp,
    required String noSim,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.updateProfile(
        noHp: noHp,
        noSim: noSim,
      );

      // Update data user yang sedang login
      currentUser = user;

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst(
        'ApiException: ',
        '',
      );

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();

    currentUser = null;
    status = AuthStatus.loggedOut;

    notifyListeners();
  }

  // ============================================================
  // GANTI PASSWORD
  // ============================================================
  Future<bool> changePassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await AuthService.changePassword(
        passwordLama: passwordLama,
        passwordBaru: passwordBaru,
      );

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst(
        'ApiException: ',
        '',
      );

      isLoading = false;
      notifyListeners();

      return false;
    }
  }
}