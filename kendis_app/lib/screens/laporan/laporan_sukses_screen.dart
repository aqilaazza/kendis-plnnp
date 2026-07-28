import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/penugasan_model.dart';

/// Ditampilkan setelah IsiLaporanScreen berhasil mengirim laporan ke server.
/// Menggantikan SnackBar + pop biasa dengan halaman konfirmasi yang lebih
/// jelas, plus ringkasan singkat & info bahwa laporan masih menunggu
/// verifikasi admin.
class LaporanSuksesScreen extends StatelessWidget {
  final PenugasanModel penugasan;
  const LaporanSuksesScreen({super.key, required this.penugasan});

  static final _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final tanggalSelesai = _formatDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verifikasi Laporan'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.12)),
                child: Icon(Icons.check_circle, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 22),
              const Text(
                'Laporan Berhasil Terkirim!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Data operasional perjalanan Anda telah tersimpan dengan aman di sistem.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5),
              ),
              const SizedBox(height: 28),

              // === Ringkasan Laporan ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RINGKASAN LAPORAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 16),
                    _RingkasanRow(label: 'Kode Request', value: penugasan.kodeRequest, valueColor: AppColors.primary),
                    const SizedBox(height: 14),
                    _RingkasanRow(label: 'Tanggal Selesai', value: tanggalSelesai),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                        const _StatusBadge(),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Kembali ke Riwayat'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Laporan Anda beserta bukti foto nota dan odometer sudah tercatat dan terverifikasi otomatis di sistem.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.4),
                      ),
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

class _RingkasanRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _RingkasanRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}

/// Laporan langsung dianggap terverifikasi begitu berhasil terkirim
/// (tidak ada proses review manual admin di alur ini).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(
        'TERVERIFIKASI',
        style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }
}