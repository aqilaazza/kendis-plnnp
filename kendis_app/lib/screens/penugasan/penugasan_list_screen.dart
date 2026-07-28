import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/penugasan_model.dart';
import '../../services/penugasan_service.dart';
import 'penugasan_detail_screen.dart';

class PenugasanListScreen extends StatefulWidget {
  const PenugasanListScreen({super.key});

  @override
  State<PenugasanListScreen> createState() => _PenugasanListScreenState();
}

class _PenugasanListScreenState extends State<PenugasanListScreen> {
  // NOTE: Figma menggunakan filter berbasis waktu (Semua / Minggu Ini / Bulan
  // Ini), bukan filter status. Jika backend masih mengharapkan status
  // (semua/menunggu/diproses/selesai), sesuaikan value di bawah ini dengan
  // yang didukung PenugasanService.getList().
  String _filter = 'semua';
  late Future<List<PenugasanModel>> _future;
  late Future<Map<String, dynamic>> _ringkasanFuture;

  @override
  void initState() {
    super.initState();
    _future = PenugasanService.getList(status: _filter);
    // getRingkasan() sekarang sudah ada di PenugasanService (menyambung ke
    // endpoint ringkasan.php yang baru).
    _ringkasanFuture = PenugasanService.getRingkasan();
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
      _future = PenugasanService.getList(status: filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF3FB),
              Color(0xFFF5F9FC),
            ],
          ),
        ),
        child: Column(
          children: [
                /// HEADER
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      /// Logo - Nama - Notifikasi
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Kendis",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              size: 30,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Riwayat Pelaporan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Daftar laporan perjalanan yang telah terkirim.",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        /// ================= BANNER (image + overlay) =================
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Ganti path asset sesuai gambar armada yang tersedia.
                                  Image.asset(
                                    'assets/images/penugasan_screen.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => Container(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(.15),
                                          Colors.black.withOpacity(.75),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const [
                                        Text(
                                          "PLN NUSANTARA POWER UP PAITON",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: .5,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          "Kualitas Armada Nomor Satu",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          "Mendukung operasional pembangkit listrik dengan armada kendaraan yang...",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// ================= FILTER (waktu) =================
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'Aktif',
                                  value: 'aktif',
                                  selected: _filter,
                                  onTap: _setFilter,
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Semmua',
                                  value: 'semua',
                                  selected: _filter,
                                  onTap: _setFilter,
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Selesai',
                                  value: 'selesai',
                                  selected: _filter,
                                  onTap: _setFilter,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// ================= SEARCH =================
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Cari laporan...",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              prefixIconColor: Colors.grey,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// ================= LIST =================
                        FutureBuilder<List<PenugasanModel>>(
                          future: _future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: Text('Gagal memuat: ${snapshot.error}')),
                              );
                            }
                            final list = snapshot.data ?? [];
                            if (list.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'Belum ada penugasan.',
                                    style: TextStyle(color: AppColors.textMuted),
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  for (final p in list) _PenugasanTile(penugasan: p),
                                ],
                              ),
                            );
                          },
                        ),

                        /// ================= RINGKASAN BULAN INI =================
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "RINGKASAN BULAN INI",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FutureBuilder<Map<String, dynamic>>(
                                  future: _ringkasanFuture,
                                  builder: (context, snap) {
                                    final r = snap.data;
                                    final jumlahLaporan = r?['jumlah_laporan']?.toString() ?? '-';
                                    final totalKm = r?['total_km']?.toString() ?? '-';
                                    final totalRupiah = r?['total_rupiah'];
                                    final totalRpLabel = totalRupiah == null
                                        ? '-'
                                        : totalRupiah >= 1000000
                                            ? '${(totalRupiah / 1000000).toStringAsFixed(1)}jt'
                                            : '${(totalRupiah / 1000).round()}rb';
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _SummaryStat(value: jumlahLaporan, label: "LAPORAN"),
                                        _SummaryStat(value: totalKm, label: "KM JARAK"),
                                        _SummaryStat(value: totalRpLabel, label: "TOTAL RP"),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onTap;
  const _FilterChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(.35) : const Color(0xFFE8EDF2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textBody,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            letterSpacing: .5,
          ),
        ),
      ],
    );
  }
}

class _PenugasanTile extends StatelessWidget {
  final PenugasanModel penugasan;

  const _PenugasanTile({
    required this.penugasan,
  });

  Color get _statusColor {
    switch (penugasan.statusRequest) {
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

  String get _statusText {
    switch (penugasan.statusRequest) {
      case 'driver_assigned':
        return 'MENUNGGU';
      case 'approved_pool':
        return 'DIPROSES';
      case 'on_trip':
        return 'ON TRIP';
      case 'completed':
        return 'SELESAI';
      default:
        return penugasan.statusLabel.toUpperCase();
    }
  }

  IconData get _statusIcon {
    switch (penugasan.statusRequest) {
      case 'on_trip':
        return Icons.local_shipping_outlined;
      case 'completed':
      case 'rated':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PenugasanDetailScreen(
                  id: penugasan.id,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER: icon + tanggal/kode + status =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_statusIcon, size: 18, color: _statusColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${penugasan.tanggalBerangkat} • ${penugasan.jamBerangkat} WIB",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            penugasan.kodeRequest,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _statusText,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFEFF2F6)),
                const SizedBox(height: 14),

                /// ================= RUTE PERJALANAN =================
                const Text(
                  "RUTE PERJALANAN",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      penugasan.tempatTujuan.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if ((penugasan.lokasiTujuan ?? '').isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                      ),
                      Expanded(
                        child: Text(
                          penugasan.lokasiTujuan!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.textBody,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                /// ================= PEMOHON / KENDARAAN =================
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PEMOHON",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            penugasan.namaPemohon ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "KENDARAAN",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            (penugasan.nopol == null && penugasan.merkKendaraan == null)
                                ? '-'
                                : "${penugasan.nopol ?? '-'} (${penugasan.merkKendaraan ?? '-'})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// ================= JADWAL PERJALANAN =================
                const Text(
                  "JADWAL PERJALANAN",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoBox(
                        title: "BERANGKAT",
                        value: "${penugasan.tanggalBerangkat}, ${penugasan.jamBerangkat}",
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                    ),
                    Expanded(
                      child: _InfoBox(
                        title: "KEMBALI",
                        value: (penugasan.tanggalKembali == null && penugasan.jamKembali == null)
                            ? "-"
                            : "${penugasan.tanggalKembali ?? '-'}, ${penugasan.jamKembali ?? '-'}",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// ================= BUTTON =================
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PenugasanDetailScreen(
                                id: penugasan.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text("Detail"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textBody,
                          side: const BorderSide(color: Color(0xFFDDE3EA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PenugasanDetailScreen(
                                id: penugasan.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text("Laporan Selesai"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A6D1E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
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

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}