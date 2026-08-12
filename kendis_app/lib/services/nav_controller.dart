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

  /// "Titipan" filter untuk PenugasanListScreen (tab Tugas). Karena
  /// screen itu persist di dalam IndexedStack (tidak dibuat ulang
  /// tiap pindah tab), filter awalnya akan tetap nempel kalau kita
  /// cuma pindah tab biasa. Nilai ini dipakai untuk memberi tahu
  /// PenugasanListScreen "tolong ganti filter ke X" tepat sebelum
  /// pindah ke tab-nya. PenugasanListScreen yang mendengarkan lalu
  /// mereset nilai ini balik ke null setelah diterapkan.
  final ValueNotifier<String?> pendingTugasFilter = ValueNotifier<String?>(null);

  /// Sama seperti [pendingTugasFilter], tapi untuk LaporanScreen.
  /// Nilai yang valid: 'perlu_diisi' atau 'riwayat'.
  final ValueNotifier<String?> pendingLaporanTab = ValueNotifier<String?>(null);

  /// Pindah ke tab dengan index tertentu.
  /// Urutan index sesuai _screens di MainNavScreen:
  /// 0 = Dashboard, 1 = Tugas, 2 = Kegiatan, 3 = Laporan, 4 = Profil
  void goTo(int index) {
    currentIndex.value = index;
  }

  /// Pindah ke tab Tugas (index 1) sekaligus menerapkan filter
  /// tertentu di sana (mis. 'semua', 'aktif', 'selesai').
  void goToTugas({String filter = 'aktif'}) {
    pendingTugasFilter.value = filter;
    goTo(1);
  }

  /// Pindah ke tab Laporan (index 3) sekaligus memilih sub-tab tertentu
  /// di sana ('perlu_diisi' atau 'riwayat').
  void goToLaporan({String tab = 'perlu_diisi'}) {
    pendingLaporanTab.value = tab;
    goTo(3);
  }
}