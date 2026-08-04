import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';
import '../../../services/nav_controller.dart'; // sesuaikan path sesuai lokasi file di project kamu
import '../../penugasan/penugasan_detail_screen.dart';

class AktivitasCard extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;

  const AktivitasCard({super.key, this.data, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // 1. Mengambil data asli saja (tidak ada data _defaultItems lagi)
    final items = data?.aktivitasTerbaru ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Aktivitas Terakhir',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // 2. Tombol Lihat Semua yang bisa diklik
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Pindah tab lewat NavController (bukan Navigator.push),
                    // supaya bottom nav tetap tampil. "Aktivitas Terakhir"
                    // isinya laporan yang sudah dikirim, jadi diarahkan
                    // langsung ke sub-tab "Riwayat" di tab Laporan.
                    NavController.instance.goToLaporanRiwayat();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3. Render list aktivitas
          if (isLoading)
            ...List.generate(
              2,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else if (items.isNotEmpty)
            ...items.map((item) => _AktivitasTile(item: item))
          else
            _EmptyState(), // Tampilkan tulisan kosong jika tidak ada aktivitas di MySQL
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Belum ada aktivitas', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _AktivitasTile extends StatelessWidget {
  final AktivitasItem item;
  const _AktivitasTile({required this.item});

  Color get _nilaiColor {
    if (item.satuan == 'rupiah' || item.jenis == 'bbm') return AppColors.danger;
    return AppColors.primary;
  }

  IconData get _icon {
    if (item.jenis == 'bbm') return Icons.local_gas_station;
    return Icons.directions_car;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.idPenugasan > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PenugasanDetailScreen(id: item.idPenugasan),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _nilaiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, size: 20, color: _nilaiColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subjudul,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formattedNilai,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _nilaiColor,
                  ),
                ),
                if (item.status.isNotEmpty)
                  Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 11,
                      color: item.status == 'Divalidasi' 
                          ? Colors.grey 
                          : AppColors.accentGold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _formattedNilai {
    final numVal = double.tryParse(item.nilai) ?? 0;
    if (item.satuan == 'rupiah' || item.jenis == 'bbm') {
      if (numVal >= 1000) {
        return 'Rp ${(numVal / 1000).toStringAsFixed(0)}rb';
      }
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(numVal);
    }
    return '${numVal.toInt()} Km';
  }
}