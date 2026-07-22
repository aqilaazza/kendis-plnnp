import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../penugasan/penugasan_list_screen.dart';
import '../laporan/laporan_screen.dart';
import '../kegiatan/kegiatan_screen.dart';
import '../profil/profil_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

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

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: color, size: 24),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}