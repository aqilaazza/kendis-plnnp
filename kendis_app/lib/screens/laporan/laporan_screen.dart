import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../models/penugasan_model.dart';
import '../../services/penugasan_service.dart';
import '../penugasan/penugasan_detail_screen.dart';

enum _RangeFilter { semua, mingguIni, bulanIni }

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  late Future<List<PenugasanModel>> _future;
  final _searchCtrl = TextEditingController();
  _RangeFilter _range = _RangeFilter.semua;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Riwayat pelaporan harus mencakup semua perjalanan yang SUDAH DIMULAI
  /// (on_trip / completed / rated), bukan cuma yang statusnya 'selesai'.
  /// Kalau cuma pakai status: 'selesai', penugasan yang sedang on_trip
  /// (laporan belum diisi driver) tidak akan pernah muncul di sini — karena
  /// status baru berubah jadi 'completed' SETELAH driver submit laporan.
  Future<List<PenugasanModel>> _loadData() async {
    final all = await PenugasanService.getList(status: 'semua');
    return all.where((p) => p.isBerangkat).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadData());
    await _future;
  }

  bool _matchesRange(PenugasanModel p) {
    if (_range == _RangeFilter.semua) return true;
    final tgl = DateTime.tryParse(p.tanggalBerangkat);
    if (tgl == null) return true;
    final now = DateTime.now();
    if (_range == _RangeFilter.bulanIni) {
      return tgl.year == now.year && tgl.month == now.month;
    }
    // Minggu ini: 7 hari terakhir dari hari ini
    final awalMinggu = now.subtract(const Duration(days: 7));
    return tgl.isAfter(awalMinggu) && tgl.isBefore(now.add(const Duration(days: 1)));
  }

  List<PenugasanModel> _applyFilters(List<PenugasanModel> list) {
    var filtered = list.where(_matchesRange).toList();
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered
          .where((p) => p.kodeRequest.toLowerCase().contains(q) || p.tempatTujuan.toLowerCase().contains(q))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<PenugasanModel>>(
            future: _future,
            builder: (context, snapshot) {
              final isLoading = snapshot.connectionState == ConnectionState.waiting;
              final allData = snapshot.data ?? [];
              final list = _applyFilters(allData);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  const Text('Riwayat Pelaporan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Daftar laporan perjalanan yang telah terkirim.',
                      style: TextStyle(color: AppColors.textBody, fontSize: 13)),
                  const SizedBox(height: 16),

                  _HeroCard(),
                  const SizedBox(height: 16),

                  _RangeFilterChips(
                    value: _range,
                    onChanged: (v) => setState(() => _range = v),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Cari laporan...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    Center(child: Text('Gagal memuat: ${snapshot.error}'))
                  else if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('Belum ada laporan yang terkirim.', style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    ...list.map((p) => _LaporanCard(penugasan: p)),

                  if (!isLoading && !snapshot.hasError && allData.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _RingkasanBulanIni(list: allData),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Kartu hero dengan foto latar PLTU Paiton + gradient overlay.
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/hero_paiton.png', fit: BoxFit.cover),
          // gradient gelap dari bawah biar teks tetap kebaca
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primaryDark.withOpacity(0.92),
                  AppColors.primaryDark.withOpacity(0.55),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'PLN NUSANTARA POWER UP PAITON',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kualitas Armada Nomor Satu',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mendukung operasional pembangkit listrik dengan armada kendaraan yang handal dan terawat.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented filter Semua / Minggu Ini / Bulan Ini.
class _RangeFilterChips extends StatelessWidget {
  final _RangeFilter value;
  final ValueChanged<_RangeFilter> onChanged;
  const _RangeFilterChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = const {
      _RangeFilter.semua: 'Semua',
      _RangeFilter.mingguIni: 'Minggu Ini',
      _RangeFilter.bulanIni: 'Bulan Ini',
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.entries.map((e) {
          final isSelected = e.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 1))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LaporanCard extends StatelessWidget {
  final PenugasanModel penugasan;
  const _LaporanCard({required this.penugasan});

  static final _rupiah = NumberFormat.decimalPattern('id_ID');

  @override
  Widget build(BuildContext context) {
    final sudahLapor = penugasan.sudahLapor;

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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: sudahLapor ? null : Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.2),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris tanggal + badge status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${penugasan.tanggalBerangkat}  •  ${penugasan.jamBerangkat} WIB',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    _StatusBadge(penugasan: penugasan),
                  ],
                ),
                const SizedBox(height: 10),

                // Rute
                Row(
                  children: [
                    Icon(sudahLapor ? Icons.check_circle : Icons.local_shipping_outlined,
                        size: 16, color: sudahLapor ? AppColors.success : AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        penugasan.lokasiTujuan != null && penugasan.lokasiTujuan!.isNotEmpty
                            ? '${penugasan.tempatTujuan} → ${penugasan.lokasiTujuan}'
                            : penugasan.tempatTujuan,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Grid info 2 kolom
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        label: 'KODE REQUEST',
                        value: penugasan.kodeRequest,
                        valueColor: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        label: 'PEMOHON',
                        value: penugasan.namaPemohon ?? '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        label: 'KOTA TUJUAN',
                        value: penugasan.tempatTujuan,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        label: 'KENDARAAN',
                        value: penugasan.nopol ?? '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        label: 'WAKTU BERANGKAT',
                        value: '${penugasan.tanggalBerangkat}, ${penugasan.jamBerangkat}',
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        label: 'TOTAL BIAYA',
                        value: sudahLapor ? 'Rp ${_rupiah.format(penugasan.totalPelaporan)}' : '-',
                        valueColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                if (!sudahLapor) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PenugasanDetailScreen(id: penugasan.id)),
                      ),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Isi Laporan'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.5, color: valueColor ?? AppColors.textBody, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PenugasanModel penugasan;
  const _StatusBadge({required this.penugasan});

  // Warna khusus untuk status 'Terkirim' (laporan sudah masuk, belum dinilai).
  static const Color _infoColor = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;

    if (!penugasan.sudahLapor) {
      // Trip sudah dimulai tapi laporan belum diisi driver.
      color = AppColors.warning;
      label = 'Perlu Diisi';
    } else if (penugasan.statusRequest == 'rated') {
      // Laporan sudah diisi dan sudah dinilai/disetujui pemohon.
      color = AppColors.success;
      label = 'Disetujui';
    } else {
      // Laporan sudah diisi (status 'completed') tapi belum dinilai.
      color = _infoColor;
      label = 'Terkirim';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

/// Panel ringkasan di bagian bawah: jumlah laporan, total KM, total biaya bulan ini.
class _RingkasanBulanIni extends StatelessWidget {
  final List<PenugasanModel> list;
  const _RingkasanBulanIni({required this.list});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bulanIni = list.where((p) {
      final tgl = DateTime.tryParse(p.tanggalBerangkat);
      return tgl != null && tgl.year == now.year && tgl.month == now.month && p.sudahLapor;
    }).toList();

    final jumlahLaporan = bulanIni.length;
    final totalKm = bulanIni.fold<int>(0, (sum, p) => sum + (p.jarakKm ?? 0));
    final totalRp = bulanIni.fold<double>(0, (sum, p) => sum + (p.totalPelaporan ?? 0));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text('RINGKASAN BULAN INI',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RingkasanStat(value: '$jumlahLaporan', label: 'Laporan'),
              _RingkasanStat(value: '$totalKm', label: 'KM Jarak'),
              _RingkasanStat(value: _formatRingkas(totalRp), label: 'Total Rp'),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatRingkas(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toStringAsFixed(0);
  }
}

class _RingkasanStat extends StatelessWidget {
  final String value;
  final String label;
  const _RingkasanStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}