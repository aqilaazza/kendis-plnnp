import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../penugasan/penugasan_list_screen.dart';
import '../laporan/laporan_screen.dart';
import '../kegiatan/kegiatan_screen.dart';
import '../profil/profil_screen.dart';
import '../../services/badge_notifier.dart'; // sesuaikan path sesuai lokasi file di project kamu
import '../../services/nav_controller.dart'; // sesuaikan path sesuai lokasi file di project kamu

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  // ==========================================================
  // BADGE COUNT
  // Nempel ke BadgeNotifier global. Begitu ada screen lain yang
  // panggil BadgeNotifier.instance.refresh() (mis. setelah submit
  // laporan / ambil kegiatan / mulai tugas), badge di sini langsung
  // ikut update tanpa perlu nunggu timer.
  // ==========================================================
  Timer? _badgeTimer;

  @override
  void initState() {
    super.initState();
    BadgeNotifier.instance.addListener(_onBadgeChanged);
    BadgeNotifier.instance.refresh();

    // Polling ringan tiap 30 detik sebagai jaring pengaman (misal ada
    // perubahan dari luar app, mis. driver lain ambil kegiatan yang sama).
    // Update instan tetap didapat dari refresh() yang dipanggil manual.
    _badgeTimer = Timer.periodic(const Duration(seconds: 30), (_) => BadgeNotifier.instance.refresh());

    // ==========================================================
    // NAV CONTROLLER
    // Dengarkan permintaan pindah tab dari widget lain (mis. tombol
    // "Buat Laporan" di BiayaCard) tanpa Navigator.push, supaya bottom
    // nav tetap tampil dan tidak perlu tombol kembali.
    // ==========================================================
    NavController.instance.currentIndex.addListener(_onNavChanged);
  }

  @override
  void dispose() {
    _badgeTimer?.cancel();
    BadgeNotifier.instance.removeListener(_onBadgeChanged);
    NavController.instance.currentIndex.removeListener(_onNavChanged);
    super.dispose();
  }

  void _onBadgeChanged() {
    if (mounted) setState(() {});
  }

  void _onNavChanged() {
    if (mounted) {
      setState(() => _currentIndex = NavController.instance.currentIndex.value);
    }
  }

  // Urutan: Dashboard, Tugas, Kegiatan (center/floating), Laporan, Profil
  final _screens = const [
    DashboardScreen(),
    PenugasanListScreen(),
    KegiatanScreen(),
    LaporanScreen(),
    ProfilScreen(),
  ];

  final _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.assignment_outlined, label: 'Tugas'),
    _NavItem(icon: Icons.grid_view_rounded, label: 'Kegiatan'), // center, dirender sbg tombol melayang
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Laporan'),
    _NavItem(icon: Icons.person_outline, label: 'Profil'),
  ];

  static const int _centerIndex = 2;

  int _badgeCountFor(int index) {
    final counts = BadgeNotifier.instance.counts;
    switch (index) {
      case 1:
        return counts.tugasBelumDijalankan;
      case 2:
        return counts.kegiatanBelumDipilih;
      case 3:
        return counts.laporanBelumDiisi;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return SizedBox(
      height: 94,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Bar putih di bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 78,
                  child: Row(
                    children: List.generate(_navItems.length, (index) {
                      if (index == _centerIndex) {
                        // Spacer kosong, karena tombolnya melayang di atas (Positioned di bawah)
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _currentIndex = index),
                            child: const SizedBox.expand(),
                          ),
                        );
                      }
                      return Expanded(child: _buildNavItem(index));
                    }),
                  ),
                ),
              ),
            ),
          ),

          // Tombol melayang untuk Kegiatan (center)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = _centerIndex),
              child: _NotificationBadge(
                count: _badgeCountFor(_centerIndex),
                large: true,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Icon(
                      _navItems[_centerIndex].icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Label "Kegiatan" di bawah tombol melayang
          Positioned(
            top: 66,
            child: SizedBox(
              width: 90,
              child: Text(
                _navItems[_centerIndex].label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _currentIndex == _centerIndex ? FontWeight.w600 : FontWeight.w400,
                  color: _currentIndex == _centerIndex ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = index == _currentIndex;
    final color = isActive ? AppColors.primary : AppColors.textMuted;
    final badgeCount = _badgeCountFor(index);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NotificationBadge(
            count: badgeCount,
            child: Icon(item.icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Indikator titik di bawah label untuk item aktif
          SizedBox(
            height: 6,
            width: 6,
            child: isActive
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Widget badge angka ala WhatsApp, "ngambang" rapi di pojok kanan-atas
/// child-nya (sedikit overhang keluar, bukan nyempil ke dalam).
/// Kalau count == 0, badge tidak ditampilkan sama sekali.
class _NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;

  /// Set true untuk child yang lebih besar (mis. tombol melayang 64px)
  /// supaya badge sedikit lebih besar & overhang-nya proporsional.
  final bool large;

  const _NotificationBadge({
    required this.child,
    required this.count,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final label = count > 99 ? '99+' : '$count';
    final overhang = large ? -6.0 : -4.0;
    final minSize = large ? 20.0 : 17.0;
    final fontSize = large ? 11.0 : 10.0;
    final borderWidth = large ? 2.0 : 1.5;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: overhang,
          right: overhang,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30), // merah ala notif WA/iOS
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}