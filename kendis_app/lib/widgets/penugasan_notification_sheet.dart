import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class PenugasanNotificationSheet {
  PenugasanNotificationSheet._();

  static Future<void> show({
    required BuildContext context,
    required String kodeRequest,
    required bool isUrgent,
    required String titikJemput,
    required String tujuanAkhir,
    required String jadwal,
    VoidCallback? onAccept,
    VoidCallback? onDismiss,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _PenugasanSheetContent(
        kodeRequest: kodeRequest,
        isUrgent: isUrgent,
        titikJemput: titikJemput,
        tujuanAkhir: tujuanAkhir,
        jadwal: jadwal,
      ),
    );
    if (result == true) {
      onAccept?.call();
    } else {
      onDismiss?.call();
    }
  }
}

class _PenugasanSheetContent extends StatelessWidget {
  const _PenugasanSheetContent({
    required this.kodeRequest,
    required this.isUrgent,
    required this.titikJemput,
    required this.tujuanAkhir,
    required this.jadwal,
  });

  final String kodeRequest;
  final bool isUrgent;
  final String titikJemput;
  final String tujuanAkhir;
  final String jadwal;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(bottom: bottomInset + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DragHandle(),
            const SizedBox(height: 8),
            _HeaderIcon(),
            const SizedBox(height: 16),
            Text(
              'Penugasan Baru!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Segera konfirmasi kesediaan Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InfoCard(
                kodeRequest: kodeRequest,
                isUrgent: isUrgent,
                titikJemput: titikJemput,
                tujuanAkhir: tujuanAkhir,
                jadwal: jadwal,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Terima Tugas'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textPlaceholder.withValues(alpha: .6),
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
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.work_outline,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.kodeRequest,
    required this.isUrgent,
    required this.titikJemput,
    required this.tujuanAkhir,
    required this.jadwal,
  });

  final String kodeRequest;
  final bool isUrgent;
  final String titikJemput;
  final String tujuanAkhir;
  final String jadwal;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .08)
              : Colors.black.withValues(alpha: .06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequestHeader(kodeRequest: kodeRequest, isUrgent: isUrgent),
          const SizedBox(height: 16),
          _Timeline(
            items: [
              _TimelineData(
                icon: Icons.near_me_outlined,
                label: 'Titik Jemput',
                value: titikJemput,
              ),
              _TimelineData(
                icon: Icons.location_on_outlined,
                label: 'Tujuan Akhir',
                value: tujuanAkhir,
              ),
              _TimelineData(
                icon: Icons.schedule_outlined,
                label: 'Jadwal',
                value: jadwal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestHeader extends StatelessWidget {
  const _RequestHeader({
    required this.kodeRequest,
    required this.isUrgent,
  });

  final String kodeRequest;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Kode Request',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              letterSpacing: .8,
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
            child: Text(
              'URGENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
                letterSpacing: .6,
              ),
            ),
          ),
      ],
    );
  }
}

class _TimelineData {
  final IconData icon;
  final String label;
  final String value;

  const _TimelineData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});

  final List<_TimelineData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: List.generate(items.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Padding(
            padding: const EdgeInsets.only(left: 14),
            child: SizedBox(
              height: 22,
              child: VerticalDivider(
                width: 2,
                thickness: 1.5,
                color: AppColors.primary.withValues(alpha: .35),
              ),
            ),
          );
        }
        final idx = i ~/ 2;
        return _TimelineRow(data: items[idx], isLast: idx == items.length - 1);
      }),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.data, required this.isLast});

  final _TimelineData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: VerticalDivider(
                    width: 2,
                    thickness: 1.5,
                    color: AppColors.primary.withValues(alpha: .2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
