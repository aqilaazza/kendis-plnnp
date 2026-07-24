import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_theme.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';

String _formatRupiah(double amount) {
  final parts = amount.toInt().toString().split('').reversed.toList();
  final chunks = <String>[];
  for (var i = 0; i < parts.length; i += 3) {
    chunks.add(parts.sublist(i, (i + 3 > parts.length) ? parts.length : i + 3).join());
  }
  return chunks.reversed.join('.');
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTugas;
  final VoidCallback? onNavigateToLaporan;
  const DashboardScreen({super.key, this.onNavigateToTugas, this.onNavigateToLaporan});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DriverDashboardModel? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _data = await DashboardService.fetchDashboard();
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException: ', '');
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_data == null) return _buildEmpty();
    return _buildContent();
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textPlaceholder),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textBody)),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text('Belum ada data.', style: TextStyle(color: AppColors.textMuted)),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Header(
            unreadCount: d.notifikasiBelumDibaca,
            onTapNotif: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(d.notifikasiBelumDibaca > 0
                    ? '${d.notifikasiBelumDibaca} notifikasi belum dibaca'
                    : 'Tidak ada notifikasi baru'), backgroundColor: AppColors.textPrimary, behavior: SnackBarBehavior.floating),
              );
            },
          ),
          const SizedBox(height: 16),
          _Greeting(name: d.driver.name, role: d.driver.role),
          const SizedBox(height: 16),
          _SummaryRow(
            summary: d.summary,
            onTapTugasAktif: widget.onNavigateToTugas,
          ),
          const SizedBox(height: 12),
          _CostCard(
            summary: d.summary,
            onTapBuatLaporan: widget.onNavigateToLaporan,
          ),
          const SizedBox(height: 16),
          _CostChart(items: d.costPeriod),
          const SizedBox(height: 16),
          _PopularDestinations(items: d.popularDestinations),
          const SizedBox(height: 16),
          _RecentActivities(
            items: d.recentActivities,
            onTapLihatSemua: widget.onNavigateToTugas,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════
class _Header extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onTapNotif;
  const _Header({this.unreadCount = 0, this.onTapNotif});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted, letterSpacing: .8)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Kendis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: onTapNotif,
              child: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount', style: TextStyle(fontSize: 9, color: Colors.white)),
                child: Icon(Icons.notifications_outlined, color: AppColors.textBody, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// GREETING
// ═══════════════════════════════════════════════
class _Greeting extends StatelessWidget {
  final String name;
  final String role;
  const _Greeting({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Halo, ',
            style: TextStyle(fontSize: 22, color: AppColors.textBody),
            children: [
              TextSpan(
                text: '$name!',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PLN Nusantara Power \u2022 $role',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// SUMMARY ROW (Tugas Aktif + Tugas Selesai)
// ═══════════════════════════════════════════════
class _SummaryRow extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback? onTapTugasAktif;
  const _SummaryRow({required this.summary, this.onTapTugasAktif});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SummaryCard(
          label: 'Tugas Aktif',
          value: summary.activeTasks.toString().padLeft(2, '0'),
          color: AppColors.primary,
          linkText: 'Lihat Detail \u2192',
          onTap: onTapTugasAktif,
        )),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(
          label: 'Tugas Selesai',
          value: summary.completedTasksWeek.toString().padLeft(2, '0'),
          color: AppColors.success,
          linkText: 'Minggu ini',
        )),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String linkText;
  final VoidCallback? onTap;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.linkText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color, height: 1.1)),
              const SizedBox(height: 6),
              Text(linkText, style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// BIAYA DILAPORKAN CARD
// ═══════════════════════════════════════════════
class _CostCard extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback? onTapBuatLaporan;
  const _CostCard({required this.summary, this.onTapBuatLaporan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BIAYA DILAPORKAN',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: .6)),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_formatRupiah(summary.reportedCostTotal)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${summary.receiptCount} Nota',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (summary.tasksNeedReport > 0)
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      'Perlu Laporan: ${summary.tasksNeedReport} Tugas',
                      style: TextStyle(fontSize: 11, color: AppColors.danger),
                    ),
                  ],
                ),
              const Spacer(),
              GestureDetector(
                onTap: onTapBuatLaporan,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Buat Laporan',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// COST PERIODE LINE CHART
// ═══════════════════════════════════════════════
class _CostChart extends StatelessWidget {
  final List<CostPeriodItem> items;
  const _CostChart({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cost Periode',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('Pengeluaran BBM, tol, dan parkir',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: .12),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= items.length) return const SizedBox();
                        final label = items[i].month.split(' ').first;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(label, style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (items.length - 1).toDouble(),
                minY: 0,
                maxY: _maxY,
                lineBarsData: [
                  _line(items.map((e) => e.bbm).toList(), AppColors.primary, 'BBM'),
                  _line(items.map((e) => e.parkir).toList(), AppColors.success, 'Parkir'),
                  _line(items.map((e) => e.tol).toList(), AppColors.accentGold, 'Tol'),
                ],
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.primary, label: 'BBM'),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.success, label: 'Parkir'),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.accentGold, label: 'Tol'),
            ],
          ),
        ],
      ),
    );
  }

  double get _maxY {
    double max = 10000;
    for (final item in items) {
      if (item.bbm > max) max = item.bbm;
      if (item.parkir > max) max = item.parkir;
      if (item.tol > max) max = item.tol;
    }
    return max * 1.2;
  }

  LineChartBarData _line(List<double> values, Color color, String label) {
    return LineChartBarData(
      spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          if (values[index] == 0) return FlDotCirclePainter(radius: 0, color: color, strokeWidth: 0);
          return FlDotCirclePainter(radius: 3, color: Colors.white, strokeWidth: 2.5, strokeColor: color);
        },
      ),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: .06)),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
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

// ═══════════════════════════════════════════════
// POPULAR DESTINATIONS DONUT
// ═══════════════════════════════════════════════
class _PopularDestinations extends StatelessWidget {
  final List<PopularDestinationItem> items;
  const _PopularDestinations({required this.items});

  @override
  Widget build(BuildContext context) {
    final top = items.isNotEmpty ? items.first : null;
    final colors = [AppColors.primary, AppColors.success, AppColors.accentGold, AppColors.warning, AppColors.textPrimary];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tujuan Dinas Terpopuler',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('5 Kota tujuan perjalanan tersering',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Belum ada data perjalanan.', style: TextStyle(color: AppColors.textMuted))),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 44,
                          sections: List.generate(items.length, (i) {
                            final total = items.fold<int>(0, (a, b) => a + b.tripCount);
                            final pct = total > 0 ? items[i].tripCount / total : 0.0;
                            return PieChartSectionData(
                              value: pct * 100,
                              color: colors[i % colors.length],
                              radius: 28,
                              showTitle: false,
                            );
                          }),
                        ),
                        duration: const Duration(milliseconds: 300),
                      ),
                      if (top != null)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(top.city, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: .5)),
                            const SizedBox(height: 2),
                            Text('${top.tripCount} Trip', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(item.city, style: TextStyle(fontSize: 11, color: AppColors.textBody), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// RECENT ACTIVITIES
// ═══════════════════════════════════════════════
class _RecentActivities extends StatelessWidget {
  final List<RecentActivityItem> items;
  final VoidCallback? onTapLihatSemua;
  const _RecentActivities({required this.items, this.onTapLihatSemua});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Aktivitas Terakhir',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const Spacer(),
            if (items.isNotEmpty)
              GestureDetector(
                onTap: onTapLihatSemua,
                child: Text('Lihat Semua',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text('Belum ada aktivitas.', style: TextStyle(color: AppColors.textMuted))),
          )
        else
          ...items.take(3).map((item) => _ActivityItem(item: item)),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final RecentActivityItem item;
  const _ActivityItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final isTrip = item.type == 'trip';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isTrip ? AppColors.primary : AppColors.accentGold).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isTrip ? Icons.directions_car_outlined : Icons.local_gas_station_outlined,
                color: isTrip ? AppColors.primary : AppColors.accentGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (item.value != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(item.value!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(item.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success)),
            ),
          ],
        ),
      ),
    );
  }
}
