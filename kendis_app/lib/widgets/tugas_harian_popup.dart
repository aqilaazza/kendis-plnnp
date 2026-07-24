import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/penugasan_model.dart';

class TugasHarianPopup {
  TugasHarianPopup._();

  static Future<void> show({
    required BuildContext context,
    required PenugasanModel task,
    VoidCallback? onTapDetail,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => _PopupBody(task: task, onTapDetail: onTapDetail),
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }
}

class _PopupBody extends StatelessWidget {
  final PenugasanModel task;
  final VoidCallback? onTapDetail;

  const _PopupBody({required this.task, this.onTapDetail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 340,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 60, offset: const Offset(0, 20)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _TaskCard(task: task),
                    const SizedBox(height: 16),
                    _ActionButton(onTap: onTapDetail),
                    const SizedBox(height: 4),
                    const _DismissHint(),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: const Column(
          children: [
            _HeaderIcon(),
            SizedBox(height: 12),
            Text(
              'Tugas Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -.3,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Ada penugasan baru untukmu',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 28),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final PenugasanModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isUrgent = task.statusRequest == 'driver_assigned';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.kodeRequest,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: .3,
                  ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'BARU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                      letterSpacing: .6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _TimelineRow(
            icon: Icons.location_on_outlined,
            label: 'Tujuan',
            value: task.tempatTujuan,
          ),
          if (task.kegiatan.isNotEmpty) ...[
            const SizedBox(height: 10),
            _TimelineRow(
              icon: Icons.work_outline,
              label: 'Kegiatan',
              value: task.kegiatan,
            ),
          ],
          const SizedBox(height: 10),
          _TimelineRow(
            icon: Icons.schedule_outlined,
            label: 'Jadwal',
            value: _formatJadwal(task),
          ),
        ],
      ),
    );
  }

  String _formatJadwal(PenugasanModel t) {
    final today = _isToday(t.tanggalBerangkat) ? 'Hari ini' : t.tanggalBerangkat;
    return '$today, ${t.jamBerangkat} WIB';
  }

  bool _isToday(String tgl) {
    try {
      final now = DateTime.now();
      final parts = tgl.split('-');
      if (parts.length == 3) {
        final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }
    } catch (_) {}
    return false;
  }
}

class _TimelineRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TimelineRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 13, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              const SizedBox(height: 1),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ActionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onTap?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: const Text('Lihat Detail'),
        ),
      ),
    );
  }
}

class _DismissHint extends StatelessWidget {
  const _DismissHint();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text(
        'Nanti Saja',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
    );
  }
}
