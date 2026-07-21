import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../services/penugasan_service.dart';
import '../laporan/isi_laporan_screen.dart';

class PenugasanDetailScreen extends StatefulWidget {
  final int id;
  const PenugasanDetailScreen({super.key, required this.id});

  @override
  State<PenugasanDetailScreen> createState() => _PenugasanDetailScreenState();
}

class _PenugasanDetailScreenState extends State<PenugasanDetailScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = PenugasanService.getDetail(widget.id);
  }

  void _reload() {
    setState(() => _future = PenugasanService.getDetail(widget.id));
  }

  Future<void> _mulaiPerjalanan() async {
    setState(() => _submitting = true);
    try {
      await PenugasanService.mulaiPerjalanan(widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perjalanan dimulai. Selamat bertugas!'), backgroundColor: AppColors.success),
      );
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Penugasan')),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat: ${snapshot.error}'));
            }
            final d = snapshot.data!;
            final isBerangkat = d['is_berangkat'].toString() == '1';
            final statusValidasi = d['status_validasi_atasan_pool'];
            final statusRequest = d['status_request'];
            final sudahAdaLaporan = d['laporan'] != null;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['kode_request'] ?? '-',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Expanded(child: Text(d['tempat_tujuan'] ?? '-', style: const TextStyle(color: Colors.white))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _SectionCard(
                  title: 'Informasi Perjalanan',
                  rows: [
                    _row('Keberangkatan', '${d['req_tgl_berangkat']}  •  ${d['jam_berangkat']}'),
                    _row('Kembali', '${d['req_tgl_kembali'] ?? '-'}  •  ${d['jam_kembali'] ?? '-'}'),
                    _row('Jumlah Penumpang', '${d['jumlah_penumpang']} orang'),
                    _row('Kegiatan', d['kegiatan'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Kendaraan',
                  rows: [
                    _row('Nomor Polisi', d['nopol'] ?? '-'),
                    _row('Merk / Warna', '${d['merk'] ?? '-'} / ${d['warna'] ?? '-'}'),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Pemohon',
                  rows: [
                    _row('Nama', d['nama_pemohon'] ?? '-'),
                    _row('No. HP', d['hp_pemohon'] ?? '-'),
                    _row('Divisi', d['divisi'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 28),

                if (statusValidasi != 'approved')
                  _InfoBanner(text: 'Menunggu validasi dari atasan pool kendis.', color: AppColors.warning)
                else if (!isBerangkat)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _mulaiPerjalanan,
                      icon: _submitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.play_arrow_rounded),
                      label: const Text('Mulai Perjalanan'),
                    ),
                  )
                else if (statusRequest == 'on_trip' && !sudahAdaLaporan)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => IsiLaporanScreen(idPenugasan: widget.id)))
                            .then((_) => _reload());
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Isi Laporan Perjalanan'),
                    ),
                  )
                else
                  _InfoBanner(text: 'Perjalanan ini sudah selesai. Terima kasih!', color: AppColors.success),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SectionCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoBanner({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
