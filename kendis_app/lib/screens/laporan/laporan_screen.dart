import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/penugasan_model.dart';
import '../../services/penugasan_service.dart';
import '../penugasan/penugasan_detail_screen.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  late Future<List<PenugasanModel>> _future;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = PenugasanService.getList(status: 'selesai');
  }

  Future<void> _refresh() async {
    setState(() => _future = PenugasanService.getList(status: 'selesai'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Riwayat Pelaporan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Daftar laporan perjalanan yang telah terkirim.', style: TextStyle(color: AppColors.textBody, fontSize: 13)),
              const SizedBox(height: 16),

              // Hero card (sesuai desain Figma)
              Container(
                width: double.infinity,
                height: 140,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.bottomLeft,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PLN NUSANTARA POWER UP PAITON', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Kualitas Armada Nomor Satu', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Cari laporan...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              FutureBuilder<List<PenugasanModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat: ${snapshot.error}'));
                  }
                  var list = snapshot.data ?? [];
                  final q = _searchCtrl.text.trim().toLowerCase();
                  if (q.isNotEmpty) {
                    list = list.where((p) =>
                        p.kodeRequest.toLowerCase().contains(q) ||
                        p.tempatTujuan.toLowerCase().contains(q)).toList();
                  }

                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text('Belum ada laporan yang terkirim.', style: TextStyle(color: AppColors.textMuted))),
                    );
                  }

                  return Column(
                    children: list.map((p) => _LaporanCard(penugasan: p)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LaporanCard extends StatelessWidget {
  final PenugasanModel penugasan;
  const _LaporanCard({required this.penugasan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PenugasanDetailScreen(id: penugasan.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${penugasan.tanggalBerangkat}  •  ${penugasan.jamBerangkat} WIB',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Selesai', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${penugasan.namaPemohon ?? "-"} → ${penugasan.tempatTujuan}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(penugasan.kodeRequest, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.directions_car, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${penugasan.nopol ?? "-"}', style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
