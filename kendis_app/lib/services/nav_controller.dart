import 'package:flutter/foundation.dart';

/// Controller global sederhana untuk pindah tab di [MainNavScreen]
/// dari widget mana pun (mis. tombol "Buat Laporan" di dashboard),
/// tanpa perlu Navigator.push (yang akan menghilangkan bottom nav).
///
/// Pola ini sama seperti BadgeNotifier yang sudah dipakai di project ini.
class NavController {
  NavController._();
  static final NavController instance = NavController._();

  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  /// Pindah ke tab dengan index tertentu.
  /// Urutan index sesuai _screens di MainNavScreen:
  /// 0 = Dashboard, 1 = Tugas, 2 = Kegiatan, 3 = Laporan, 4 = Profil
  void goTo(int index) {
    currentIndex.value = index;
  }
}