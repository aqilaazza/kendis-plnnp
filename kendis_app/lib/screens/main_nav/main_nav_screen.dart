import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../penugasan/penugasan_list_screen.dart';
import '../laporan/laporan_screen.dart';
import '../kegiatan/kegiatan_screen.dart';
import '../profil/profil_screen.dart';
import '../../services/badge_service.dart'; // sesuaikan path sesuai lokasi file di project kamu

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  // ==========================================================
  // BADGE COUNT STATE
  // Diisi dari endpoint GET /notifikasi/badge_count.php lewat BadgeService.
  // ==========================================================
  int _penugasanBelumDijalankan = 0; // index 1 (Tugas)
  int _kegiatanBelumDipilih = 0;     // index 2 (Kegiatan, tombol tengah)
  int _laporanBelumDiisi = 0;        // index 3 (Laporan)

  Timer? _badgeTimer;

  @override
  void initState() {
    super.initState();
    _loadBadgeCounts();

    // Auto-refresh badge tiap 60 detik
    _badgeTimer = Timer.periodic(const Duration(seconds: 60), (_) => _loadBadgeCounts());
  }

  @override
  void dispose() {
    _badgeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBadgeCounts() async {
    try {
      final counts = await BadgeService.fetchBadgeCounts();
      if (!mounted) return;
      setState(() {
        _penugasanBelumDijalankan = counts.tugasBelumDijalankan;
        _kegiatanBelumDipilih = counts.kegiatanBelumDipilih;
        _laporanBelumDiisi = counts.laporanBelumDiisi;
      });
    } catch (e) {
      // Gagal ambil badge (misal koneksi lagi jelek) 
      debugPrint('Gagal memuat badge count: $e');
    }
  }

  /// Panggil method ini dari child screen 
  void refreshBadges() => _loadBadgeCounts();

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
    switch (index) {
      case 1:
        return _penugasanBelumDijalankan;
      case 2:
        return _kegiatanBelumDipilih;
      case 3:
        return _laporanBelumDiisi;
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
                badgeOffset: const Offset(4, -2),
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

/// Widget badge angka ala WhatsApp, ditempel di pojok kanan-atas child-nya.
/// Kalau count == 0, badge tidak ditampilkan sama sekali.
class _NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Offset badgeOffset;

  const _NotificationBadge({
    required this.child,
    required this.count,
    this.badgeOffset = const Offset(2, -2),
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final label = count > 99 ? '99+' : '$count';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: badgeOffset.dy,
          right: badgeOffset.dx,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30), // merah ala notif WA/iOS
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
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