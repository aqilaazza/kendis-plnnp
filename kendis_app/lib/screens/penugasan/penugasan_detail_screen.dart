import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../models/penugasan_model.dart';
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

  Color _statusColor(String? statusRequest) {
    switch (statusRequest) {
      case 'on_trip':
        return AppColors.warning;
      case 'completed':
      case 'rated':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  String _statusText(String? statusRequest, String? statusLabel) {
    switch (statusRequest) {
      case 'driver_assigned':
        return 'MENUNGGU';
      case 'approved_pool':
        return 'DIPROSES';
      case 'on_trip':
        return 'ON TRIP';
      case 'completed':
        return 'SELESAI';
      default:
        return (statusLabel ?? statusRequest ?? '-').toString().toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  _Header(onBack: () => Navigator.of(context).pop()),
                  const Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  _Header(onBack: () => Navigator.of(context).pop()),
                  Expanded(child: Center(child: Text('Gagal memuat: ${snapshot.error}'))),
                ],
              );
            }

            final d = snapshot.data!;
            final isBerangkat = d['is_berangkat'].toString() == '1';
            final statusValidasi = d['status_validasi_atasan_pool'];
            final statusRequest = d['status_request']?.toString();
            final sudahAdaLaporan = d['laporan'] != null;
            final color = _statusColor(statusRequest);

            // NOTE: field-field berikut belum tersedia di payload/model saat ini,
            // jadi ditampilkan hanya jika ada di response API (kalau backend
            // sudah menyertakannya), dan disembunyikan/pakai fallback kalau tidak:
            // - timestamp per-tahap (diajukan/persetujuan/driver berangkat) untuk
            //   progress tracker di atas — saat ini ditampilkan tanpa tanggal
            //   spesifik karena tidak ada field created_at/approved_at/dst.
            // - info driver (nama & no HP) — d['nama_driver'] / d['hp_driver']
            // - d['surat_penugasan'] (url/file) untuk tombol "Lihat File"
            // - d['catatan_pool']
            final namaDriver = d['nama_driver']?.toString();
            final hpDriver = d['hp_driver']?.toString();
            final suratPenugasan = d['surat_penugasan']?.toString();
            final catatanPool = d['catatan_pool']?.toString();
            final divisi = d['divisi']?.toString();

            return Column(
              children: [
                _Header(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ================= PROGRESS TRACKER =================
                        _ProgressTracker(statusRequest: statusRequest, isBerangkat: isBerangkat, statusValidasi: statusValidasi),

                        const SizedBox(height: 20),

                        /// ================= CARD DETAIL =================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      "Laporan Realisasi",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(.15),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      _statusText(statusRequest, null),
                                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              _DetailRow(label: "KODE REQUEST", value: d['kode_request'] ?? '-', valueColor: AppColors.primary),
                              _DetailRow(
                                label: "PEMOHON",
                                value: "${d['nama_pemohon'] ?? '-'}${divisi != null ? ' ($divisi)' : ''}",
                              ),
                              _DetailRow(label: "NO HP PEMOHON", value: d['hp_pemohon'] ?? '-'),
                              _DetailRow(
                                label: "TUJUAN",
                                value: d['tempat_tujuan'] ?? '-',
                                subValue: d['lokasi_tujuan'],
                              ),

                              /// WAKTU
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("WAKTU", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_available, size: 16, color: AppColors.success),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${d['req_tgl_berangkat'] ?? d['tanggal_berangkat'] ?? '-'}, ${d['jam_berangkat'] ?? '-'}",
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                    if (d['req_tgl_kembali'] != null || d['tanggal_kembali'] != null) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.event_busy, size: 16, color: AppColors.danger),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${d['req_tgl_kembali'] ?? d['tanggal_kembali']}",
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Container(height: 1, color: const Color(0xFFEFF2F6)),
                                  ],
                                ),
                              ),

                              _DetailRow(label: "KEGIATAN", value: d['kegiatan'] ?? '-'),
                              _DetailRow(label: "PENUMPANG", value: "${d['jumlah_penumpang'] ?? '-'} orang"),

                              if (namaDriver != null) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("DRIVER", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(namaDriver,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          if (d['tipe_driver'] == 'official') ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF0F2F5),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text("OFFICIAL",
                                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(height: 1, color: const Color(0xFFEFF2F6)),
                                    ],
                                  ),
                                ),
                                _DetailRow(label: "NO HP DRIVER", value: hpDriver ?? '-'),
                              ],

                              _DetailRow(
                                label: "KENDARAAN",
                                value: "${d['nopol'] ?? '-'} - ${d['merk'] ?? '-'} (${d['warna'] ?? '-'})",
                                icon: Icons.directions_car_filled_outlined,
                              ),

                              if (suratPenugasan != null) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("SURAT PENUGASAN",
                                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      OutlinedButton.icon(
                                        // TODO: tambahkan package url_launcher lalu buka
                                        // `suratPenugasan` sebagai URL, atau arahkan ke
                                        // viewer PDF internal kalau berupa file lokal.
                                        onPressed: () {},
                                        icon: const Icon(Icons.description_outlined, size: 16),
                                        label: const Text("Lihat File"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(color: Color(0xFFDDE3EA)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(height: 1, color: const Color(0xFFEFF2F6)),
                                    ],
                                  ),
                                ),
                              ],

                              if (catatanPool != null)
                                _DetailRow(label: "CATATAN POOL", value: catatanPool, isLast: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ================= AKSI (mengikuti status penugasan) =================
                        if (statusValidasi != 'approved')
                          _InfoBanner(text: 'Menunggu validasi dari atasan pool kendis.', color: AppColors.warning)
                        else if (!isBerangkat)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitting ? null : _mulaiPerjalanan,
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.play_arrow_rounded),
                              label: const Text('Mulai Perjalanan'),
                            ),
                          )
                        else if (statusRequest == 'on_trip' && !sudahAdaLaporan)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // IsiLaporanScreen sekarang butuh objek PenugasanModel (bukan
                                // cuma id) supaya bisa nampilin kartu "Informasi Perjalanan"
                                // di atas form tanpa fetch ulang. Data detail di sini masih
                                // berupa Map<String, dynamic> mentah dari API, jadi di-convert
                                // dulu pakai PenugasanModel.fromJson(...).
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => IsiLaporanScreen(penugasan: PenugasanModel.fromJson(d))))
                                    .then((_) => _reload());
                              },
                              icon: const Icon(Icons.receipt_long),
                              label: const Text('Isi Laporan Perjalanan'),
                            ),
                          )
                        else
                          _InfoBanner(text: 'Perjalanan ini sudah selesai. Terima kasih!', color: AppColors.success),
                      ],
                    ),
                  ),
                ),

                /// ================= TOMBOL TUTUP =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEFF2F6))),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Tutup"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Header kustom (bukan AppBar bawaan) supaya gayanya sama dengan header di
/// PenugasanListScreen: back arrow, judul, ikon notifikasi, avatar.
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          const Expanded(
            child: Text(
              "Detail Penugasan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 26, color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Tracker 3 tahap (Diajukan / Persetujuan / Driver Berangkat). Backend saat
/// ini tidak mengirim timestamp per-tahap, jadi hanya status selesai/belum
/// yang ditampilkan — tambahkan field seperti created_at/approved_at di API
/// kalau ingin menampilkan tanggal per-tahap seperti pada Figma.
class _ProgressTracker extends StatelessWidget {
  final String? statusRequest;
  final bool isBerangkat;
  final dynamic statusValidasi;

  const _ProgressTracker({required this.statusRequest, required this.isBerangkat, required this.statusValidasi});

  @override
  Widget build(BuildContext context) {
    final step2Done = statusValidasi == 'approved' ||
        ['approved_pool', 'on_trip', 'completed', 'rated'].contains(statusRequest);
    final step3Done = isBerangkat || ['on_trip', 'completed', 'rated'].contains(statusRequest);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(child: _StepNode(label: "DIAJUKAN", done: true)),
          _StepLine(done: step2Done),
          Expanded(child: _StepNode(label: "PERSETUJUAN", done: step2Done)),
          _StepLine(done: step3Done),
          Expanded(child: _StepNode(label: "DRIVER BERANGKAT", done: step3Done)),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  final String label;
  final bool done;
  const _StepNode({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : const Color(0xFFD8DEE5);
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(done ? Icons.check : Icons.circle, color: Colors.white, size: done ? 16 : 8),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: done ? AppColors.success : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool done;
  const _StepLine({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: done ? AppColors.success : const Color(0xFFD8DEE5),
    );
  }
}

/// Satu baris label/value di kartu detail, dengan divider tipis di bawahnya
/// (kecuali baris terakhir).
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color? valueColor;
  final IconData? icon;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
    this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.textPrimary),
                ),
              ),
            ],
          ),
          if (subValue != null && subValue!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subValue!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
          if (!isLast) ...[
            const SizedBox(height: 8),
            Container(height: 1, color: const Color(0xFFEFF2F6)),
          ],
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