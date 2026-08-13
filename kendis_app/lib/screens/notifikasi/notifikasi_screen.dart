import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';
import '../../models/notifikasi_model.dart';
import '../../services/notifikasi_service.dart';
import '../../services/badge_notifier.dart';
import '../laporan/laporan_screen.dart';
import '../penugasan/penugasan_list_screen.dart';
import '../kegiatan/kegiatan_screen.dart';

/// Screen daftar notifikasi dengan tab filter: Semua / Belum Dibaca / Riwayat.
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  final Map<String, List<NotifikasiModel>> _cache = {
    'semua': [],
    'belum_dibaca': [],
    'riwayat': [],
  };

  final Map<String, bool> _loading = {
    'semua': true,
    'belum_dibaca': true,
    'riwayat': true,
  };

  final Map<String, String?> _error = {
    'semua': null,
    'belum_dibaca': null,
    'riwayat': null,
  };

  /// ID yang lagi diproses mark-read-nya, biar tombol centang bisa
  /// nunjukin loading kecil & nggak ke-tap dobel.
  final Set<int> _markingRead = {};

  static const _tabs = ['semua', 'belum_dibaca', 'riwayat'];
  static const _tabLabels = {
    'semua': 'Semua',
    'belum_dibaca': 'Belum Dibaca',
    'riwayat': 'Riwayat',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _tabs.indexOf('belum_dibaca'),
    );
    for (final filter in _tabs) {
      _loadData(filter);
    }

    // Refresh data saat app kembali dari background (timer polling pause
    // waktu app di background, jadi biar tidak nunggu interval lagi).
    WidgetsBinding.instance.addObserver(this);

    // Dengarkan BadgeNotifier 
    BadgeNotifier.instance.addListener(_onBadgeChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
      BadgeNotifier.instance.refresh();
    }
  }

  void _onBadgeChanged() {
    if (!mounted) return;
    _refreshAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BadgeNotifier.instance.removeListener(_onBadgeChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData(String filter) async {
    setState(() {
      _loading[filter] = true;
      _error[filter] = null;
    });
    try {
      final data = await NotifikasiService.getList(filter: filter);
      if (!mounted) return;
      setState(() {
        _cache[filter] = data;
        _loading[filter] = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error[filter] = e.toString();
        _loading[filter] = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait(_tabs.map(_loadData));
  }

  Future<void> _markAllRead() async {
    try {
      await NotifikasiService.markAllRead();
      await _refreshAll();
      BadgeNotifier.instance.refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menandai semua: $e')),
      );
    }
  }

  /// Tandai satu notifikasi sudah dibaca lewat tombol centang.
  /// Item ini bakal "pindah" ke tab Riwayat / hilang dari Belum Dibaca
  /// begitu data di-refresh. Setelah berhasil, panggil BadgeNotifier.refresh()
  /// supaya badge lonceng di layar lain (Dashboard/Laporan/Penugasan) ikut
  /// update instan.
  Future<void> _markOneRead(NotifikasiModel item) async {
    if (item.isRead || _markingRead.contains(item.id)) return;
    setState(() => _markingRead.add(item.id));
    try {
      await NotifikasiService.markRead(item.id);
      await _refreshAll();
      BadgeNotifier.instance.refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menandai dibaca: $e')),
      );
    } finally {
      if (mounted) setState(() => _markingRead.remove(item.id));
    }
  }

  /// Tap di badan card (judul/pesan) HANYA navigasi ke menu terkait.
  /// TIDAK menandai notifikasi sebagai sudah dibaca -- itu murni tugas
  /// tombol centang (_markOneRead), supaya user tetap bisa lihat status
  /// belum-dibaca-nya walau sudah pernah buka halaman tugasnya.
  ///
  /// Push langsung ke widget screen (bukan Navigator.pushNamed) supaya
  /// tidak bergantung pada route terdaftar di MaterialApp.
  ///
  /// `idRequest` dikirim sebagai `highlightId` supaya screen tujuan bisa
  /// auto-pilih tab yang tepat, auto-scroll, dan highlight card yang
  /// berkaitan dengan notifikasi ini -- bukan cuma buka list kosongan.
  void _handleTap(NotifikasiModel item) {
    // Untuk notifikasi penugasan/laporan, idRequest berisi request_kendis.id.
    // Khusus kegiatan, backend menyimpan id kegiatan di kolom id_kegiatan
    // (id_request-nya NULL), jadi dipakai itu untuk highlight.
    final highlightId =
        item.kategori?.trim().toLowerCase() == 'kegiatan'
            ? item.idKegiatan ?? item.idRequest
            : item.idRequest;
    // Dibikin toleran (trim + lowercase) -- kalau backend ngirim "Penugasan"
    // atau ada spasi nyempil, tetep ke-detect. Sebelumnya switch ini pakai
    // exact-match string sensitif kapital/spasi, jadi kalau nilai kategori
    // dari API meleset dikit aja, jatuh ke default dan diem tanpa error.
    var kategori = item.kategori?.trim().toLowerCase();

    // Fallback: sebagian notifikasi (mis. yang ditujukan untuk pemohon di
    // web, seperti "Perjalanan Dimulai" / "Perjalanan Selesai - Berikan
    // Penilaian" dari pilih_kendaraan.php, mulai.php, laporan/submit.php)
    // tidak mengisi kolom kategori sama sekali. Daripada langsung dianggap
    // error, coba tebak dulu dari judulnya supaya tetap bisa diarahkan
    // kalau relevan buat driver.
    if (kategori == null || kategori.isEmpty) {
      kategori = _inferKategoriFromJudul(item.judul);
    }

    switch (kategori) {
      case 'penugasan':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PenugasanListScreen(highlightId: highlightId),
          ),
        );
        break;
      case 'laporan':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LaporanScreen(highlightId: highlightId),
          ),
        );
        break;
      case 'kegiatan':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KegiatanScreen(highlightId: highlightId),
          ),
        );
        break;
      default:
        // Kategori nggak dikenali & nggak ketebak dari judul -- kemungkinan
        // besar ini notifikasi yang memang ditujukan untuk halaman web
        // (bukan untuk app driver), jadi cukup diinfokan tanpa terkesan
        // seperti error/debug.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi ini tidak memiliki halaman terkait di aplikasi ini.'),
          ),
        );
        break;
    }
  }

  /// Tebakan kasar kategori dari judul notifikasi, dipakai HANYA sebagai
  /// fallback ketika backend tidak mengisi kolom `kategori` sama sekali.
  /// Cocokkan kata kunci yang biasa dipakai pada judul notifikasi terkait
  /// masing-masing fitur (penugasan/laporan/kegiatan).
  String? _inferKategoriFromJudul(String judul) {
    final j = judul.toLowerCase();
    if (j.contains('kegiatan')) return 'kegiatan';
    if (j.contains('laporan')) return 'laporan';
    if (j.contains('pengugasan') ||
        j.contains('penugasan') ||
        j.contains('perjalanan') ||
        j.contains('kendaraan')) {
      return 'penugasan';
    }
    return null;
  }

  /// Aksi gabungan tombol centang: tandai dibaca SEKALIGUS langsung
  /// navigasi + highlight ke halaman terkait -- satu tap, dua aksi.
  Future<void> _markReadAndNavigate(NotifikasiModel item) async {
    await _markOneRead(item);
    if (!mounted) return;
    _handleTap(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Tandai semua',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _PillTabBar(controller: _tabController, tabs: _tabs, labels: _tabLabels),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map(_buildTabBody).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(String filter) {
    if (_loading[filter] == true) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error[filter] != null) {
      return _buildErrorState(filter);
    }

    final items = _cache[filter] ?? [];

    if (items.isEmpty) {
      return _buildEmptyState(filter);
    }

    final groups = _groupByDate(items);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadData(filter),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: groups.length,
        itemBuilder: (context, groupIndex) {
          final group = groups[groupIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 2),
                child: Text(
                  group.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...group.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NotifikasiCard(
                    item: item,
                    isMarking: _markingRead.contains(item.id),
                    onTap: () => _handleTap(item),
                    onMarkRead: () => _markReadAndNavigate(item),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Kelompokkan notifikasi jadi "Hari Ini" / "Kemarin" / tanggal lain
  /// (list sudah terurut DESC dari backend, jadi urutan grup ikut terjaga).
  List<_NotifGroup> _groupByDate(List<NotifikasiModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<NotifikasiModel>>{};
    final order = <String>[];

    for (final item in items) {
      final d = item.createdAt;
      final day = DateTime(d.year, d.month, d.day);
      String label;
      if (day == today) {
        label = 'Hari Ini';
      } else if (day == yesterday) {
        label = 'Kemarin';
      } else {
        const bulan = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
        ];
        label = '${d.day} ${bulan[d.month - 1]} ${d.year}';
      }
      if (!groups.containsKey(label)) {
        groups[label] = [];
        order.add(label);
      }
      groups[label]!.add(item);
    }

    return order.map((label) => _NotifGroup(label, groups[label]!)).toList();
  }

  Widget _buildErrorState(String filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              _error[filter] ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadData(filter),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    final message = switch (filter) {
      'belum_dibaca' => 'Tidak ada notifikasi yang belum dibaca',
      'riwayat' => 'Belum ada riwayat notifikasi',
      _ => 'Belum ada notifikasi',
    };

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: AppColors.textPlaceholder,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
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

class _NotifGroup {
  final String label;
  final List<NotifikasiModel> items;
  _NotifGroup(this.label, this.items);
}

/// Tab bar bentuk pill (kapsul) sesuai desain — tab aktif jadi
/// background gelap solid, bukan underline seperti TabBar default.
class _PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final Map<String, String> labels;

  const _PillTabBar({
    required this.controller,
    required this.tabs,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          children: List.generate(tabs.length, (i) {
            final selected = controller.index == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.animateTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryDark : AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    labels[tabs[i]] ?? tabs[i],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _NotifikasiCard extends StatelessWidget {
  final NotifikasiModel item;
  final bool isMarking;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  const _NotifikasiCard({
    required this.item,
    required this.isMarking,
    required this.onTap,
    required this.onMarkRead,
  });

  /// Icon + warna per kategori/tipe notifikasi.
  /// Tipe yang mengandung kata "peringatan" atau "belum_dipilih" dianggap
  /// warning (merah/pink), sisanya dipetakan dari kategori.
  (IconData, Color, Color) get _iconStyle {
    final tipe = item.tipe ?? '';
    if (tipe.contains('peringatan') || tipe.contains('belum_dipilih')) {
      return (Icons.warning_amber_rounded, AppColors.danger, const Color(0xFFFCE8E8));
    }
    switch (item.kategori) {
      case 'penugasan':
        return (Icons.assignment_outlined, AppColors.primary, AppColors.primary.withOpacity(0.12));
      case 'laporan':
        return (Icons.receipt_long_outlined, AppColors.primary, AppColors.primary.withOpacity(0.12));
      case 'kegiatan':
        return (Icons.event_note_outlined, AppColors.accentGold, AppColors.accentGold.withOpacity(0.15));
      default:
        return (Icons.notifications_outlined, AppColors.accentGold, AppColors.accentGold.withOpacity(0.15));
    }
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    final (icon, iconColor, iconBg) = _iconStyle;

    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unread ? AppColors.primary.withOpacity(0.2) : AppColors.backgroundAlt,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (unread)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6, top: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: item.judul,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: '  •  ${_formatWaktu(item.createdAt)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.pesan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textBody),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _MarkReadButton(isRead: item.isRead, isLoading: isMarking, onTap: onMarkRead),
            ],
          ),
        ),
      ),
    );
  }
}

/// FIX: sebelumnya pakai GestureDetector biasa -- karena tombol ini nempel
/// di dalam InkWell besar (card di atasnya), tap-nya sering "ketelan" sama
/// InkWell card, jadi yang kepencet malah navigasi card, bukan mark-read.
class _MarkReadButton extends StatelessWidget {
  final bool isRead;
  final bool isLoading;
  final VoidCallback onTap;

  const _MarkReadButton({
    required this.isRead,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 26,
        height: 26,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isRead ? null : onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRead ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: isRead ? AppColors.success : AppColors.textPlaceholder,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 16,
            color: isRead ? Colors.white : AppColors.textPlaceholder,
          ),
        ),
      ),
    );
  }
}