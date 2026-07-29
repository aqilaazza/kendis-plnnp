import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

enum DashboardLoadState { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  DashboardLoadState state = DashboardLoadState.initial;
  DashboardModel? data;
  String? errorMessage;
  bool isServerError = false;

  Future<void> load() async {
    state = DashboardLoadState.loading;
    errorMessage = null;
    isServerError = false;
    notifyListeners();

    try {
      data = await DashboardService.load().timeout(const Duration(seconds: 30));
      state = DashboardLoadState.loaded;
    } catch (e) {
      _setError(e);
      state = DashboardLoadState.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  void _setError(Object e) {
    if (e is ApiException) {
      final sc = e.statusCode;
      if (sc == 401) {
        errorMessage = 'Sesi Anda telah berakhir. Silakan login ulang.';
        isServerError = false;
      } else if (sc == null || sc >= 500) {
        errorMessage =
            'Server sedang sibuk. Coba lagi beberapa saat, atau hubungi admin.';
        isServerError = true;
      } else {
        errorMessage = e.message;
        isServerError = false;
      }
    } else if (e is TimeoutException) {
      errorMessage = 'Waktu habis — pastikan koneksi internet Anda stabil.';
      isServerError = true;
    } else {
      errorMessage =
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      isServerError = true;
    }
  }
}

// ignore_for_file: unused_element, unused_local_variable
// Extension points for future API integration:
//
//   // TODO: panggil endpoint notifikasi
//   data?.notifikasiUnread = ...
//
//   // TODO: panggil endpoint biaya per kategori
//   data?.biayaPerKategori = ...
//
//   // TODO: panggil endpoint top kota tujuan
//   data?.topCities = ...
//
//   // TODO: panggil endpoint aktivitas terbaru
//   data?.aktivitasTerbaru = ...
