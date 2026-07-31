import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/penugasan_menunggu_model.dart';

const _kTeal = Color(0xFF0B5563);
const _kCardBg = Color(0xFFF3F6F7);
const _kTextGray = Color(0xFF6B7280);
const _kUrgentText = Color(0xFF8B7B2E);

class PenugasanNotificationSheet {
  PenugasanNotificationSheet._();

  /// Tampilkan bottom sheet notifikasi penugasan baru.
  ///
  /// [onAccept] dipanggil saat tombol "Terima Tugas" ditekan.
  /// Fungsi ini harus mengembalikan true jika sukses, false jika gagal
  /// (sheet akan tetap terbuka dan menampilkan error).
  ///
  /// Solusi sementara: konfirmasi hanya disimpan lokal di SharedPreferences
  /// sampai ada kolom konfirmasi driver di database.
  static Future<void> show({
    required BuildContext context,
    required PenugasanMenungguModel penugasan,
    required Future<bool> Function() onAccept,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .4),
      builder: (_) => _SheetContent(
        penugasan: penugasan,
        onAccept: onAccept,
      ),
    );
  }

  static String formatJadwal(DateTime? dt) {
    if (dt == null) return '-';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SheetContent extends StatefulWidget {
  final PenugasanMenungguModel penugasan;
  final Future<bool> Function() onAccept;

  const _SheetContent({
    required this.penugasan,
    required this.onAccept,
  });

  @override
  State<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent> {
  bool _isAccepting = false;
  String? _errorMessage;

  Future<void> _handleAccept() async {
    setState(() {
      _isAccepting = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onAccept();
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isAccepting = false;
          _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAccepting = false;
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.75;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom + 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final p = widget.penugasan;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          const SizedBox(height: 20),
          _HeaderIcon(),
          const SizedBox(height: 16),
          Text(
            'Penugasan Baru!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _kTeal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Segera konfirmasi ketersediaan Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _kTextGray,
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            kodeRequest: p.kodeRequest,
            isUrgent: p.isUrgent,
            lokasiTujuan: p.lokasiTujuan,
            tempatTujuan: p.tempatTujuan,
            jadwalFormatted: PenugasanNotificationSheet.formatJadwal(p.jadwal),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          _AcceptButton(
            isAccepting: _isAccepting,
            onPressed: _isAccepting ? null : _handleAccept,
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: _kTeal.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF2),
        shape: BoxShape.circle,
        border: Border.all(
          color: _kTeal.withValues(alpha: .15),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.assignment_outlined,
        color: _kTeal,
        size: 32,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String kodeRequest;
  final bool isUrgent;
  final String lokasiTujuan;
  final String tempatTujuan;
  final String jadwalFormatted;

  const _InfoCard({
    required this.kodeRequest,
    required this.isUrgent,
    required this.lokasiTujuan,
    required this.tempatTujuan,
    required this.jadwalFormatted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequestHeader(),
          const SizedBox(height: 4),
          Text(
            kodeRequest,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _TimelineSection(
            lokasiTujuan: lokasiTujuan,
            tempatTujuan: tempatTujuan,
          ),
          const SizedBox(height: 12),
          _JadwalRow(jadwal: jadwalFormatted),
        ],
      ),
    );
  }

  Widget _buildRequestHeader() {
    return Row(
      children: [
        Text(
          'KODE REQUEST',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _kTextGray,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        if (isUrgent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'URGENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kUrgentText,
                letterSpacing: 0.6,
              ),
            ),
          ),
      ],
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final String lokasiTujuan;
  final String tempatTujuan;

  const _TimelineSection({
    required this.lokasiTujuan,
    required this.tempatTujuan,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _TimelineDot(filled: true),
              Expanded(
                child: SizedBox(
                  width: 2,
                  child: CustomPaint(
                    painter: _DashedLinePainter(
                      color: _kTextGray.withValues(alpha: .35),
                    ),
                  ),
                ),
              ),
              _TimelineDot(filled: false),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimelineRow(
                  label: 'Lokasi Tujuan',
                  value: lokasiTujuan.isNotEmpty ? lokasiTujuan : tempatTujuan,
                ),
                const SizedBox(height: 24),
                _TimelineRow(
                  label: 'Tujuan Akhir',
                  value: tempatTujuan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final bool filled;

  const _TimelineDot({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: filled ? _kTeal : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: _kTeal,
          width: 2,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, (startY + dashWidth).clamp(0, size.height)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String value;

  const _TimelineRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _kTextGray,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class _JadwalRow extends StatelessWidget {
  final String jadwal;

  const _JadwalRow({required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: _kTeal),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JADWAL',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _kTextGray,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              jadwal,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AcceptButton extends StatelessWidget {
  final bool isAccepting;
  final VoidCallback? onPressed;

  const _AcceptButton({
    required this.isAccepting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kTeal,
          disabledBackgroundColor: _kTeal.withValues(alpha: .6),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isAccepting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Terima Tugas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
