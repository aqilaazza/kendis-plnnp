import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../models/penugasan_menunggu_model.dart';

class PenugasanNotificationSheet {
  /// Tampilkan popup notifikasi penugasan baru.
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
      isScrollControlled:
          true, // Tambahkan ini agar sheet bisa tampil penuh jika konten panjang
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
  State<_PenugasanNotificationContent> createState() =>
      _PenugasanNotificationContentState();
}

class _PenugasanNotificationContentState
    extends State<_PenugasanNotificationContent> {
  bool _isSubmitting = false;

  bool get _isUrgent => widget.penugasan.isUrgent;
  String get _formattedJadwal => widget.penugasan.jadwalFormatted;

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              // ----- ICON LINGKARAN (Diperbarui sesuai gambar) -----
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFF0F4F5), // Warna latar belakang abu-abu muda
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.grey.shade300, width: 2), // Garis tepi
                ),
                child: const Center(
                  child: Icon(
                    Icons
                        .assignment_late, // Ikon yang lebih mirip clipboard dengan tanda seru
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ----- JUDUL -----
              const Text(
                'Penugasan Baru!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Segera konfirmasi ketersediaan Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // ----- CARD DETAIL -----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.kodeRequest,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFF9EED4), // Warna latar kuning pudar
                              borderRadius: BorderRadius.circular(
                                  8), // Sudut tidak terlalu bulat
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                    0xFF8B6B15), // Warna teks coklat/emas gelap
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Titik Jemput -> Tujuan Akhir (Diperbarui dengan garis putus-putus)
                    _buildRoutePoint(
                      icon: Icons.circle,
                      iconColor: AppColors.primary,
                      iconSize: 12,
                      label: 'Titik Jemput',
                      value: 'PLN Nusantara Power HQ, Jakarta',
                    ),

                    // Garis Putus-putus (Dashed Line) buatan manual
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5.5, top: 4, bottom: 4),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => Container(
                            width: 1.5,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),

                    _buildRoutePoint(
                      icon:
                          Icons.radio_button_unchecked, // Ikon lingkaran kosong
                      iconColor: AppColors.primary,
                      iconSize: 12,
                      label: 'Tujuan Akhir',
                      value: p.tempatTujuan,
                    ),
                    const SizedBox(height: 24),

                    // Jadwal
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 12),
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
                            const SizedBox(height: 2),
                            Text(
                              _formattedJadwal,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight
                                    .bold, // Ditebalkan agar sesuai gambar
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
              const SizedBox(height: 24),

              // ----- TOMBOL TERIMA TUGAS -----
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleAccept,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline, size: 22),
                  label: Text(_isSubmitting ? 'Memproses...' : 'Terima Tugas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)), // Sudut sedikit kotak
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ----- GARIS BAWAH -----
              Container(
                width: double.infinity,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
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
          padding: const EdgeInsets.only(top: 2),
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
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
