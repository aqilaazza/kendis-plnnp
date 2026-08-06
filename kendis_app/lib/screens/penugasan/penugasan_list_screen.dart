import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/penugasan_model.dart';
import '../../services/penugasan_service.dart';
import '../notifikasi/notifikasi_screen.dart';
import 'penugasan_detail_screen.dart';

/// Berapa lama border+background highlight tetap menyala sebelum pudar.
const Duration _kHighlightDuration = Duration(seconds: 4);

class PenugasanListScreen extends StatefulWidget {
  /// id_request dari notifikasi (kalau screen ini dibuka lewat notifikasi).
  final int? highlightId;

  const PenugasanListScreen({super.key, this.highlightId});

  @override
  State<PenugasanListScreen> createState() => _PenugasanListScreenState();
}

class _PenugasanListScreenState extends State<PenugasanListScreen> {
  // NOTE: Figma menggunakan filter berbasis waktu (Semua / Minggu Ini / Bulan
  // Ini), bukan filter status. 
  late String _filter;
  late Future<List<PenugasanModel>> _future;
  late Future<Map<String, dynamic>> _ringkasanFuture;
  late Future<int> _aktifCountFuture;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  /// Key buat auto-scroll ke card yang di-highlight dari notifikasi.
  final GlobalKey _highlightKey = GlobalKey();
  bool _scrolledToHighlight = false;

  /// Kontrol tampil/pudarnya border+bg highlight (terpisah dari
  /// widget.highlightId supaya scroll-matching tetap jalan walau glow-nya
  /// udah pudar).
  bool _highlightGlowVisible = false;
  Timer? _highlightFadeTimer;

  @override
  void initState() {
    super.initState();
    // Kalau datang dari notifikasi, mulai dari filter 'semua' supaya item
    // yang dituju pasti muncul di list, apapun statusnya.
    _filter = widget.highlightId != null ? 'semua' : 'aktif';
    _loadAll();
    _searchCtrl.addListener(_onSearchChanged);

    if (widget.highlightId != null) {
      _highlightGlowVisible = true;
      _scheduleHighlightFadeOut();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _highlightFadeTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _scheduleHighlightFadeOut() {
    _highlightFadeTimer?.cancel();
    _highlightFadeTimer = Timer(_kHighlightDuration, () {
      if (!mounted) return;
      setState(() => _highlightGlowVisible = false);
    });
  }

  /// Load ulang list (sesuai filter+search aktif), ringkasan bulan ini, dan
  /// badge count "Aktif" — dipanggil dari initState, RefreshIndicator, ganti
  /// filter, maupun search.
  void _loadAll() {
    _future = PenugasanService.getList(status: _filter, search: _searchCtrl.text);
    _ringkasanFuture = PenugasanService.getRingkasan();
    // Jumlah data untuk badge chip "Aktif" — diambil terpisah supaya angkanya
    // tetap tampil walaupun user sedang berada di filter Semua/Selesai.
    // Sengaja tidak ikut search, biar badge selalu menunjukkan total aktif.
    _aktifCountFuture = PenugasanService.getList(status: 'aktif').then((l) => l.length);
  }

  /// Dipanggil oleh RefreshIndicator (tarik ke bawah untuk refresh).
  Future<void> _onRefresh() async {
    setState(_loadAll);
    await _future;
  }

  void _onSearchChanged() {
    // Debounce 400ms supaya tidak nembak API tiap kali user mengetik satu
    // huruf — request baru dikirim setelah user berhenti mengetik sejenak.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _future = PenugasanService.getList(status: _filter, search: _searchCtrl.text);
      });
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
      _future = PenugasanService.getList(status: filter, search: _searchCtrl.text);
    });
  }

  /// Scroll otomatis ke card yang highlightId-nya cocok, sekali saja
  /// (dijaga oleh `_scrolledToHighlight`).
  void _maybeScrollToHighlight(List<PenugasanModel> list) {
    if (widget.highlightId == null || _scrolledToHighlight) return;
    // PENTING: highlightId yang dikirim dari notifikasi itu adalah
    // id_request (request_kendis.id)
    final found = list.any((p) => p.idRequest == widget.highlightId);
    if (!found) return;
    _scrolledToHighlight = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _highlightKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              /// HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    /// Judul - Notifikasi
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tombol kembali -- cuma muncul kalau screen ini
                        // dibuka lewat push (mis. dari notifikasi), bukan
                        // waktu jadi tab utama di bottom nav.
                        if (Navigator.of(context).canPop())
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textPrimary,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (Navigator.of(context).canPop()) const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Riwayat Penugasan",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            size: 30,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Daftar penugasan yang telah terkirim.",
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
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                    children: [
                      const SizedBox(height: 16),

                      /// ================= FILTER (waktu) =================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FutureBuilder<int>(
                                future: _aktifCountFuture,
                                builder: (context, snap) {
                                  return _FilterChip(
                                    label: 'Aktif',
                                    value: 'aktif',
                                    selected: _filter,
                                    onTap: _setFilter,
                                    count: snap.data,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Semua',
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
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: "Cari laporan...",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchCtrl.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () => _searchCtrl.clear(),
                                  ),
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

                          _maybeScrollToHighlight(list);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                for (final p in list)
                                  _PenugasanTile(
                                    // Dicocokkan ke idRequest (request_kendis.id), bukan p.id
                                    // (penugasan.id) -- lihat catatan di _maybeScrollToHighlight.
                                    key: p.idRequest == widget.highlightId ? _highlightKey : null,
                                    penugasan: p,
                                    highlighted: _highlightGlowVisible && p.idRequest == widget.highlightId,
                                  ),
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
              ),
            ],
          ),
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
  final int? count;
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.count,
  });

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textBody,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            // Badge angka jumlah data — hanya ditampilkan kalau count diisi
            // (dipakai khusus untuk chip "Aktif"). Warna kuning (warning)
            // solid, sama seperti badge "Perlu Diisi" di layar Laporan.
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
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

  /// True kalau card ini yang dituju dari notifikasi DAN glow-nya belum
  /// pudar -- dikasih border gold + tag "Dari Notifikasi". Otomatis jadi
  /// false lagi setelah beberapa detik (lihat _scheduleHighlightFadeOut di
  /// parent), dan AnimatedContainer di bawah yang bikin transisinya halus,
  /// bukan hilang tiba-tiba.
  final bool highlighted;

  const _PenugasanTile({
    super.key,
    required this.penugasan,
    this.highlighted = false,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Border & warna selalu "ada", cuma warnanya transparan kalau
              // nggak highlighted -- supaya AnimatedContainer bisa nge-lerp
              // transisinya jadi pudar halus, bukan muncul/hilang instan.
              border: Border.all(
                color: highlighted ? AppColors.accentGold : Colors.transparent,
                width: 2,
              ),
              color: highlighted ? AppColors.accentGold.withOpacity(0.05) : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: highlighted
                      ? Column(
                          key: const ValueKey('highlight-tag'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.notifications_active, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Dari Notifikasi',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        )
                      : const SizedBox(key: ValueKey('no-tag'), width: double.infinity),
                ),
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