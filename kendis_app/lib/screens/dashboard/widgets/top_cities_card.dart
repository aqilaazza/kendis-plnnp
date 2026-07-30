import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';

class TopCitiesCard extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;

  const TopCitiesCard({super.key, this.data, required this.isLoading});

  static const _pieColors = [
    Color(0xFF0B5563),
    Color(0xFF10707F),
    Color(0xFF1F9D8F),
    Color(0xFFC9A227),
    Color(0xFFE8A838),
  ];

  @override
  Widget build(BuildContext context) {
    final cities = data?.topCities;

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
          const Text('Tujuan Dinas Terpopuler',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          const Text('5 Kota tujuan perjalanan tersering', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Hanya merender chart jika ada data dari MySQL
          if (isLoading)
            Container(height: 200, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)))
          else if (cities != null && cities.isNotEmpty)
            _PieChart(cities: cities)
          else
            _EmptyPie(),
        ],
      ),
    );
  }
}

class _EmptyPie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Data belum tersedia', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final List<TopCity> cities;
  const _PieChart({required this.cities});

  @override
  Widget build(BuildContext context) {
    final total = cities.fold(0, (int sum, c) => sum + c.jumlahTrip);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: List.generate(cities.length, (i) {
                    final city = cities[i];
                    final pct = total > 0 ? city.jumlahTrip / total * 100 : 0.0;
                    return PieChartSectionData(
                      value: city.jumlahTrip.toDouble(),
                      color: TopCitiesCard._pieColors[i % TopCitiesCard._pieColors.length],
                      radius: 40,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cities.first.kota,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Text('${cities.first.jumlahTrip} Trip',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _PieLegend(cities: cities),
      ],
    );
  }
}

class _PieLegend extends StatelessWidget {
  final List<TopCity> cities;
  const _PieLegend({required this.cities});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List.generate(cities.length, (i) {
        final city = cities[i];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: TopCitiesCard._pieColors[i % TopCitiesCard._pieColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text('${city.kota} (${city.jumlahTrip})', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        );
      }),
    );
  }
}