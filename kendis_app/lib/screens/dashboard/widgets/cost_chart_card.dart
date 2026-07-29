import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';

class CostChartCard extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;

  const CostChartCard({super.key, this.data, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final categories = data?.biayaPerKategori;

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
          Text('Cost Periode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('Pengeluaran BBM, tol, dan parkir', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          if (isLoading)
            Container(height: 180, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)))
          else if (categories != null && categories.isNotEmpty)
            _Chart(categories: categories)
          else
            _EmptyChart(),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Data belum tersedia', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<CostByCategory> categories;
  const _Chart({required this.categories});

  @override
  Widget build(BuildContext context) {
    final spotsBbm = <FlSpot>[];
    final spotsParkir = <FlSpot>[];
    final spotsTol = <FlSpot>[];
    for (var i = 0; i < categories.length; i++) {
      final c = categories[i];
      spotsBbm.add(FlSpot(i.toDouble(), c.bbm));
      spotsParkir.add(FlSpot(i.toDouble(), c.parkir));
      spotsTol.add(FlSpot(i.toDouble(), c.tol));
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= categories.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(categories[idx].label,
                            style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                _lineData(spotsBbm, const Color(0xFF0B5563)),
                _lineData(spotsParkir, const Color(0xFF1F9D8F)),
                _lineData(spotsTol, const Color(0xFFC9A227)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Legend(),
      ],
    );
  }

  LineChartBarData _lineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 2.5,
      isCurved: true,
      curveSmoothness: 0.3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: Colors.white,
          strokeWidth: 2,
          strokeColor: color,
        ),
      ),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.08)),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(const Color(0xFF0B5563), 'BBM'),
        const SizedBox(width: 20),
        _legendDot(const Color(0xFF1F9D8F), 'Parkir'),
        const SizedBox(width: 20),
        _legendDot(const Color(0xFFC9A227), 'Tol'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}