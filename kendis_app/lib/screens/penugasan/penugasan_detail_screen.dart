import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../config/app_config.dart';
import '../../models/penugasan_model.dart';
import '../../services/penugasan_service.dart';
import '../../services/badge_notifier.dart';
import '../laporan/isi_laporan_screen.dart';
import 'pilih_kendaraan_screen.dart';

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
      BadgeNotifier.instance.refresh(); // <-- TAMBAHAN: status berubah -> badge Tugas langsung update
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Ditekan dari tombol "Mulai Perjalanan". Kalau kendaraan untuk penugasan
  /// ini belum dipilih (nopol masih null), buka dulu popup Pilih Kendaraan —
  /// popup itu sendiri yang sekaligus memulai perjalanan begitu dikonfirmasi.
  /// Kalau kendaraan sudah ada (mis. penugasan lama / sudah pernah dipilih),
  /// langsung mulai perjalanan seperti biasa tanpa perlu pilih kendaraan lagi.
  Future<void> _onTapMulaiPerjalanan(Map<String, dynamic> d) async {
    if (d['nopol'] == null) {
      final started = await showPilihKendaraanDialog(context, int.parse(d['id'].toString()));
      if (started) {
        BadgeNotifier.instance.refresh(); // <-- TAMBAHAN: jaga-jaga kalau dialog belum refresh sendiri
        _reload();
      }
    } else {
      await _mulaiPerjalanan();
    }
  }

  /// Surat penugasan diupload lewat website Kendis (asman), disimpan sebagai
  /// path relatif dari root folder uploads yang sama dengan foto kendaraan
  /// (lihat pilih_kendaraan_screen.dart). Dibuka lewat endpoint file.php
  /// milik kendis_api sendiri, bukan ditebak path fisiknya langsung, supaya
  /// tetap benar walau lokasi folder uploads di server beda.
  /// NOTE: file.php ada di kendis_api/penugasan/file.php (bukan di root
  /// kendis_api), jadi URL-nya WAJIB menyertakan segmen /penugasan/ —
  /// kalau tidak, request 404 sebelum sempat sampai ke file.php sama sekali.
  static String _fileUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConfig.baseUrl}/penugasan/file.php?path=${Uri.encodeComponent(path)}';
  }

  Future<void> _lihatSuratPenugasan(String suratPenugasan) async {
    final url = Uri.parse(_fileUrl(suratPenugasan));
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada aplikasi untuk membuka file ini'), backgroundColor: AppColors.danger),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka file: $e'), backgroundColor: AppColors.danger),
      );
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
                        _ProgressTracker(data: d),

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
                                        onPressed: () => _lihatSuratPenugasan(suratPenugasan),
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
                              onPressed: _submitting ? null : () => _onTapMulaiPerjalanan(d),
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
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Tutup"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
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
/// PenugasanListScreen: back arrow, judul, ikon notifikasi.
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
        ],
      ),
    );
  }
}

/// Ringkasan progres (kartu biru "Perjalanan — Step 5 dari 6 — 83% Progress")
/// yang bisa diklik untuk membuka/menutup rincian "Riwayat Proses" di
/// bawahnya (daftar 6 tahap dengan status & waktu masing-masing).
///
/// Waktu tiap tahap dan status selesai/belumnya ditarik dari data yang
/// sudah nyata ada di backend (lihat detail.php): tanggal_diajukan
/// (request_kendis.created_at), tanggal_persetujuan_atasan/tanggal_driver_
/// ditunjuk/tanggal_persetujuan_pool/tanggal_mulai (dari tabel notifikasi),
/// dan tanggal_selesai (laporan_driver.created_at). Sebuah tahap dianggap
/// "selesai" kalau timestamp-nya ada isinya; status_request/is_berangkat
/// cuma dipakai sebagai fallback kalau timestamp itu ternyata null (mis.
/// data lama sebelum notifikasi tercatat).
class _ProgressTracker extends StatefulWidget {
  final Map<String, dynamic> data;
  const _ProgressTracker({required this.data});

  @override
  State<_ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<_ProgressTracker> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final statusRequest = d['status_request']?.toString();

    final tglPersetujuanAtasan = d['tanggal_persetujuan_atasan']?.toString();
    final tglDriverDitunjuk = d['tanggal_driver_ditunjuk']?.toString();
    final tglPersetujuanPool = d['tanggal_persetujuan_pool']?.toString();
    final tglMulai = d['tanggal_mulai']?.toString();
    final tglSelesai = d['tanggal_selesai']?.toString() ?? d['tanggal_lapor']?.toString();

    // Fallback ke status enum kalau timestamp-nya null (mis. data lawas).
    final persetujuanAtasanDone = tglPersetujuanAtasan != null ||
        ['approved_atasan', 'pool_received', 'driver_assigned', 'approved_pool', 'on_trip', 'completed', 'rated'].contains(statusRequest);
    final driverDitunjukDone = tglDriverDitunjuk != null ||
        ['driver_assigned', 'approved_pool', 'on_trip', 'completed', 'rated'].contains(statusRequest);
    final persetujuanPoolDone = tglPersetujuanPool != null || ['approved_pool', 'on_trip', 'completed', 'rated'].contains(statusRequest);
    final selesaiDone = tglSelesai != null || ['completed', 'rated'].contains(statusRequest);
    // "Perjalanan" baru dianggap selesai (centang hijau) kalau seluruh siklus
    // sudah kelar (selesaiDone) — selama masih on_trip, tahap ini harus tetap
    // jadi "current" (bukan done), supaya current-step & progress bar gak
    // ikut melompat ke "Selesai" padahal laporan belum masuk.
    final perjalananDone = selesaiDone;

    final steps = <_TimelineStep>[
      _TimelineStep(
        label: "Diajukan",
        desc: "Request berhasil diajukan",
        icon: Icons.assignment_outlined,
        done: true,
        time: d['tanggal_diajukan']?.toString(),
      ),
      _TimelineStep(
        label: "Persetujuan Atasan",
        desc: "Disetujui oleh atasan",
        icon: Icons.how_to_reg_outlined,
        done: persetujuanAtasanDone,
        time: tglPersetujuanAtasan,
      ),
      _TimelineStep(
        label: "Driver Ditunjuk",
        desc: "Driver telah ditunjuk",
        icon: Icons.person_pin_circle_outlined,
        done: driverDitunjukDone,
        time: tglDriverDitunjuk,
      ),
      _TimelineStep(
        label: "Persetujuan Pool",
        desc: "Disetujui oleh pool",
        icon: Icons.verified_outlined,
        done: persetujuanPoolDone,
        time: tglPersetujuanPool,
      ),
      _TimelineStep(
        label: "Perjalanan",
        desc: "Sedang dalam perjalanan",
        icon: Icons.directions_car_filled_rounded,
        done: perjalananDone,
        time: tglMulai,
      ),
      _TimelineStep(
        label: "Selesai",
        desc: "Menunggu perjalanan selesai",
        icon: Icons.flag_outlined,
        done: selesaiDone,
        time: tglSelesai,
      ),
    ];

    final currentIndex = steps.indexWhere((s) => !s.done);
    final allDone = currentIndex == -1;
    final currentStepNumber = allDone ? steps.length : currentIndex + 1;
    final progressPercent = ((currentStepNumber / steps.length) * 100).round();
    final currentLabel = allDone ? "Selesai" : steps[currentIndex].label;

    return Column(
      children: [
        /// ================= KARTU RINGKASAN =================
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Icon(
                      allDone ? Icons.flag_outlined : steps[currentIndex].icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            allDone ? "Selesai" : "Sedang Berlangsung",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(currentLabel,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text("Step $currentStepNumber dari ${steps.length}",
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("$progressPercent%",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const Text("Progress", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// ================= SEGMENTED PROGRESS BAR =================
        Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              if (i != 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < currentStepNumber ? AppColors.primary : const Color(0xFFE3E7EC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ],
        ),

        /// ================= RIWAYAT PROSES (expand/collapse) =================
        if (_expanded) ...[
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _expanded = false),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: Text("Riwayat Proses",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ),
                        Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < steps.length; i++)
                      _TimelineStepTile(
                        step: steps[i],
                        isCurrent: i == currentIndex,
                        isLast: i == steps.length - 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimelineStep {
  final String label;
  final String desc;
  final IconData icon;
  final bool done;
  final String? time;
  const _TimelineStep({required this.label, required this.desc, required this.icon, required this.done, this.time});
}

class _TimelineStepTile extends StatelessWidget {
  final _TimelineStep step;
  final bool isCurrent;
  final bool isLast;
  const _TimelineStepTile({required this.step, required this.isCurrent, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = step.done ? AppColors.success : (isCurrent ? AppColors.primary : const Color(0xFFD8DEE5));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: step.done ? AppColors.success : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: step.done
                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                    : (isCurrent ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))) : null),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: color.withOpacity(.4))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.label,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: step.done || isCurrent ? AppColors.textPrimary : AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(step.desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(step.time ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
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