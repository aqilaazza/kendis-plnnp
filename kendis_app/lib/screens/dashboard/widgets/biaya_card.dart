import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';
import '../../../services/nav_controller.dart'; // sesuaikan path sesuai lokasi file di project kamu

class BiayaCard extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;

  const BiayaCard({super.key, this.data, required this.isLoading});

  // Index tab "Laporan" di MainNavScreen (lihat _screens di main_nav_screen.dart)
  static const int _laporanTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    final total = data?.totalRupiahBulanIni;
    final jumlahNota = data?.jumlahLaporanBulanIni;
    final perluLaporan = data?.perluLaporan;

    return Container(
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'BIAYA DILAPORKAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        if (isLoading)
                          Container(
                            width: 60,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          )
                        else if (jumlahNota != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006780).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$jumlahNota Nota',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      Container(
                        width: 140,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    else if (total != null)
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(total),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Logika diperbaiki agar tidak muncul angka 3 jika kosong
                        if (perluLaporan != null && perluLaporan > 0)
                          Text(
                            'Perlu Laporan: $perluLaporan Tugas',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          const Text(
                            'Tidak ada laporan tertunda',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          // FIX: sebelumnya Navigator.push ke LaporanScreen
                          // sebagai halaman baru (bottom nav hilang, tidak
                          // ada tombol kembali). Sekarang cukup pindah tab
                          // lewat NavController, IndexedStack di
                          // MainNavScreen yang urus tampilannya, bottom nav
                          // tetap ada.
                          onPressed: () => NavController.instance.goTo(_laporanTabIndex),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Buat Laporan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}