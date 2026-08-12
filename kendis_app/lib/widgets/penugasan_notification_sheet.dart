import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/penugasan_menunggu_model.dart';

class PenugasanNotificationSheet {
  /// Tampilkan popup notifikasi penugasan baru.
  ///
  /// [onAccept] dipanggil saat tombol "Terima Tugas" ditekan.
  /// Return `true` dari [onAccept] untuk menutup sheet otomatis,
  /// return `false` (atau lempar exception) untuk membiarkan sheet
  /// tetap terbuka (misal karena gagal, biar user bisa coba lagi).
  static Future<void> show({
    required BuildContext context,
    required PenugasanMenungguModel penugasan,
    required Future<bool> Function() onAccept,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _PenugasanNotificationContent(
        penugasan: penugasan,
        onAccept: onAccept,
      ),
    );
  }
}

class _PenugasanNotificationContent extends StatefulWidget {
  final PenugasanMenungguModel penugasan;
  final Future<bool> Function() onAccept;

  const _PenugasanNotificationContent({
    required this.penugasan,
    required this.onAccept,
  });

  @override
  State<_PenugasanNotificationContent> createState() => _PenugasanNotificationContentState();
}

class _PenugasanNotificationContentState extends State<_PenugasanNotificationContent> {
  bool _isSubmitting = false;

  Future<void> _handleAccept() async {
    setState(() => _isSubmitting = true);
    try {
      final success = await widget.onAccept();
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.penugasan;

    // Gabungkan tempat tujuan + detail lokasi (kalau ada) untuk baris
    // "Tujuan Akhir", mis. "SURABAYA - Kantor Pusat".
    final tujuanLengkap = p.lokasiTujuan.isNotEmpty
        ? '${p.tempatTujuan} - ${p.lokasiTujuan}'
        : p.tempatTujuan;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ----- ICON LINGKARAN -----
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_late_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // ----- JUDUL -----
              const Text(
                'Penugasan Baru!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Segera konfirmasi ketersediaan Anda',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),

              // ----- CARD DETAIL -----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kode Request + badge Urgent
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KODE REQUEST',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.kodeRequest,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (p.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Titik Jemput -> Tujuan Akhir (dengan garis penghubung)
                    _buildRoutePoint(
                      icon: Icons.circle,
                      iconColor: AppColors.primary,
                      iconSize: 10,
                      label: 'TITIK JEMPUT',
                      // Catatan: model belum punya field khusus titik
                      // jemput, jadi dipakai teks tetap. Ganti dengan
                      // field yang sesuai kalau nanti tersedia dari API.
                      value: 'PLN Nusantara Power HQ, Jakarta',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.5),
                      child: Column(
                        children: List.generate(
                          4,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Container(
                              width: 1,
                              height: 3,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildRoutePoint(
                      icon: Icons.circle_outlined,
                      iconColor: AppColors.accentGold,
                      iconSize: 10,
                      label: 'TUJUAN AKHIR',
                      value: tujuanLengkap,
                    ),
                    const SizedBox(height: 16),

                    // Jadwal
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'JADWAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              p.jadwalFormatted,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ----- TOMBOL TERIMA TUGAS -----
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleAccept,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(_isSubmitting ? 'Memproses...' : 'Terima Tugas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePoint({
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}