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

  /// Sinyal buat LaporanScreen: kalau true, begitu tab Laporan dibuka lewat
  /// goTo()/goToLaporanRiwayat(), dia langsung pindah ke sub-tab "Riwayat"
  /// (bukan default "Perlu Diisi"). LaporanScreen yang reset ini balik ke
  /// false setelah dikonsumsi, supaya tap manual di bottom nav "Laporan"
  /// tetap buka default "Perlu Diisi" seperti biasa.
  final ValueNotifier<bool> laporanJumpToRiwayat = ValueNotifier<bool>(false);

  /// Pindah ke tab dengan index tertentu.
  /// Urutan index sesuai _screens di MainNavScreen:
  /// 0 = Dashboard, 1 = Tugas, 2 = Kegiatan, 3 = Laporan, 4 = Profil
  void goTo(int index) {
    currentIndex.value = index;
  }

  /// Shortcut: pindah ke tab Laporan sekaligus minta dia buka langsung di
  /// sub-tab "Riwayat" -- dipakai dari AktivitasCard di Dashboard, karena
  /// datanya (laporan yang sudah dikirim) lebih related ke Riwayat
  /// daripada "Perlu Diisi".
  void goToLaporanRiwayat() {
    laporanJumpToRiwayat.value = true;
    goTo(3);
  }
}