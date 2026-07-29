import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';
import '../../penugasan/penugasan_list_screen.dart';

class StatsDuoCard extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;

  const StatsDuoCard({super.key, this.data, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCard(context, 'Tugas Aktif', data?.tugasAktif ?? 0, Icons.assignment_add, AppColors.primary, 'Lihat Detail', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PenugasanListScreen()));
        })),
        const SizedBox(width: 12),
        Expanded(child: _buildCard(context, 'Tugas Selesai', data?.tugasSelesai ?? 0, Icons.check_circle_outline, AppColors.success, 'Minggu ini', null)),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String label, int value, IconData icon, Color color, String sublabel, VoidCallback? onTap) {
    return Container(
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -12,
            child: Icon(icon, size: 80, color: color.withOpacity(0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const Spacer(),
                if (isLoading)
                  Container(width: 40, height: 28, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(6)))
                else
                  Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                const Spacer(),
                if (onTap != null)
                  GestureDetector(
                    onTap: onTap,
                    child: Text(sublabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGold)),
                  )
                else
                  Text(sublabel, style: TextStyle(fontSize: 12, color: AppColors.accentGold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
