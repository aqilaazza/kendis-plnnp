import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, loggedIn, loggedOut }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? errorMessage;
  bool isLoading = false;

  Future<void> checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();

    status = loggedIn ? AuthStatus.loggedIn : AuthStatus.loggedOut;

    notifyListeners();
  }

  Future<bool> login(
    String nid,
    String password,
  ) async {
    isLoading = true;
    errorMessage = null;
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
      errorMessage = e.toString().replaceFirst(
            'ApiException: ',
            '',
          );

      isLoading = false;

      notifyListeners();

      return false;
    }
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
}
