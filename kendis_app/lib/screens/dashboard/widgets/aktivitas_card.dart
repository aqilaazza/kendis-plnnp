import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';

class AktivitasCard extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;

  const AktivitasCard({super.key, this.data, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final items = data?.aktivitasTerbaru;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Aktivitas Terakhir',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            ...List.generate(3, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                      height: 56,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12))),
                ))
          else if (items != null && items.isNotEmpty)
            ...items.map((item) => _AktivitasTile(item: item))
          else
            _EmptyState(),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.jenis == 'bbm' ? Icons.local_gas_station : Icons.directions_car,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.judul,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(item.subjudul, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formattedNilai,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
              if (item.status.isNotEmpty)
                Text(item.status, style: const TextStyle(fontSize: 11, color: AppColors.accentGold)),
            ],
          ),
        ],
      ),
    );
  }

  String get _formattedNilai {
    final numVal = double.tryParse(item.nilai) ?? 0;
    if (item.satuan == 'rupiah') {
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(numVal);
    }
    return '${numVal.toInt()} Km';
  }
}