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
          const Text('Cost Periode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          const Text('Pengeluaran BBM, tol, dan parkir', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Logika untuk menampilkan data ASLI saja
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 500000,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              // Klip semua elemen (termasuk overshoot kurva melengkung) biar
              // gak ada yang nembus keluar area plot / kepotong aneh sama
              // batas kontainer.
              clipData: const FlClipData.all(),
              minY: 0,
              maxY: _maxY,
              // Kunci sumbu X: 1 tick per titik data, mencegah label
              // bulan/tahun terduplikasi akibat auto-interval fl_chart.
              // Domain dikasih sedikit margin (-0.4 / +0.4) di kiri-kanan —
              // tanpa ini, titik pertama & terakhir nempel persis di tepi
              // area chart, jadi label bulannya (Mar 2026 / Agu 2026) kepotong
              // setengah karena gak ada ruang buat teksnya "napas".
              minX: -0.4,
              maxX: (categories.length - 1) + 0.4,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= categories.length) return const SizedBox.shrink();
                      // Hindari render dobel akibat pembulatan titik non-integer
                      if ((value - idx).abs() > 0.01) return const SizedBox.shrink();

                      // Label bulan dari backend sudah berisi bulan + tahun
                      // (misal: "Jul 2026"), jadi cukup tampilkan apa adanya.
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(categories[idx].label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // Tanpa dua flag ini, tooltip di titik-titik dekat tepi
                  // kanan (mis. Agustus, titik terakhir) nongol nembus ke
                  // luar batas chart/card — itu yang bikin kepotong.
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final labels = ['BBM', 'Parkir', 'Tol'];
                      final colors = [const Color(0xFF0B5563), const Color(0xFF1F9D8F), const Color(0xFFC9A227)];
                      final barIdx = spot.barIndex;
                      final label = barIdx < labels.length ? labels[barIdx] : '';
                      final color = barIdx < colors.length ? colors[barIdx] : Colors.grey;
                      return LineTooltipItem(
                        '$label: Rp ${_formatRupiah(spot.y)}',
                        TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                      );
                    }).toList();
                  },
                ),
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

  double get _maxY {
    double max = 0;
    for (final c in categories) {
      if (c.bbm > max) max = c.bbm;
      if (c.parkir > max) max = c.parkir;
      if (c.tol > max) max = c.tol;
    }
    // Headroom dinaikkan dari 1.2x ke 1.35x — puncak kurva BBM sebelumnya
    // mepet/kepotong di batas atas chart waktu kenaikannya tajam.
    return max > 0 ? max * 1.35 : 1000000;
  }

  String _formatRupiah(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}rb';
    return value.toStringAsFixed(0);
  }

  LineChartBarData _lineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 3,
      isCurved: true,
      // Smoothness diturunkan sedikit (0.3 -> 0.22) plus overshoot-prevention
      // diaktifkan — ini kombinasi yang bikin garis tetap melengkung halus
      // tapi gak "membuncit" ngelewatin nilai data aslinya (itu yang bikin
      // puncak BBM kelihatan kepotong sebelumnya).
      curveSmoothness: 0.22,
      preventCurveOverShooting: true,
      preventCurveOvershootingThreshold: 10,
      dotData: const FlDotData(show: false),
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
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}