import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/penugasan_service.dart';
import 'penugasan_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = PenugasanService.getDashboard();
  }

  Future<void> _refresh() async {
    setState(() => _dashboardFuture = PenugasanService.getDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final userNama = context.watch<AuthProvider>().currentUser?.nama ?? 'Driver';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text('Gagal memuat data: ${snapshot.error}')),
                ],
              );
            }

            final data = snapshot.data!;
            final stats = data['statistik'] as Map<String, dynamic>;
            final penugasanAktif = data['penugasan_aktif'] as List;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Halo, $userNama 👋',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text('Semoga perjalananmu selalu lancar.', style: TextStyle(color: AppColors.textBody)),
                const SizedBox(height: 20),

                // Hero card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PLN NUSANTARA POWER UP PAITON',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Kualitas Armada Nomor Satu',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'Mendukung operasional pembangkit listrik dengan armada kendaraan yang siap sedia.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistik ringkas
                Row(
                  children: [
                    _StatCard(label: 'Tugas Aktif', value: '${stats['tugas_aktif']}', color: AppColors.primary),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Selesai', value: '${stats['tugas_selesai']}', color: AppColors.success),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Rating',
                      value: stats['rata_rating'] != null ? '${stats['rata_rating']} ★' : '-',
                      color: AppColors.accentGold,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Penugasan Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),

                if (penugasanAktif.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Text('Belum ada penugasan aktif saat ini.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  )
                else
                  ...penugasanAktif.map((p) => _PenugasanCard(data: p)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _PenugasanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PenugasanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PenugasanDetailScreen(id: int.parse(data['id'].toString()))),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['kode_request'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(data['tempat_tujuan'] ?? '-', style: TextStyle(fontSize: 13, color: AppColors.textBody)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
