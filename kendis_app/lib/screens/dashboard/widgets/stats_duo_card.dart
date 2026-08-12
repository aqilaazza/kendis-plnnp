import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';
import '../../../services/nav_controller.dart'; // sesuaikan path sesuai lokasi file di project kamu

class StatsDuoCard extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;

  const StatsDuoCard({super.key, this.data, required this.isLoading});

  // Index tab "Tugas" di MainNavScreen (lihat _screens di main_nav_screen.dart)
  static const int _tugasTabIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Kartu Tugas Aktif (Dapat diklik untuk menuju daftar tugas)
        Expanded(
          child: _buildCard(
            context: context,
            label: 'Tugas Aktif',
            value: data?.tugasAktif ?? 0,
            icon: Icons.assignment_add,
            color: AppColors.primary,
            sublabel: 'Lihat Detail',
            showArrow: true,
            // FIX: sebelumnya Navigator.push ke PenugasanListScreen
            // sebagai halaman baru (bottom nav hilang). Sekarang pindah
            // tab lewat NavController, bottom nav tetap tampil, dan
            // filter di halaman Riwayat Penugasan otomatis diset ke
            // "Semua" (bukan "Aktif" yang jadi default screen itu).
            onTap: () => NavController.instance.goToTugas(filter: 'semua'),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Kartu Tugas Selesai
        Expanded(
          child: _buildCard(
            context: context,
            label: 'Tugas Selesai',
            value: data?.tugasSelesai ?? 0,
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            sublabel: 'Minggu ini',
            showArrow: false,
            onTap: () => NavController.instance.goToTugas(filter: 'semua'),
          ),
        ),
      ],
    );
  }

  /// Helper Widget untuk membuat Kartu Statistik
  Widget _buildCard({
    required BuildContext context,
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required String sublabel,
    required bool showArrow,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Ikon Latar Belakang
              Positioned(
                right: -12,
                bottom: -12,
                child: Icon(
                  icon,
                  size: 80,
                  color: color.withOpacity(0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Kartu
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),

                    // Nilai Angka (dengan tampilan loading)
                    if (isLoading)
                      Container(
                        width: 40,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                    else
                      Text(
                        value.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    const Spacer(),

                    // Tombol / Sublabel Bawah
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sublabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGold,
                          ),
                        ),
                        if (showArrow) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.accentGold,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}