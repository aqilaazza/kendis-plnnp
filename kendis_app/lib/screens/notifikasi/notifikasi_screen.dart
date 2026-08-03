import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';
import '../../models/notifikasi_model.dart';
import '../../services/notifikasi_service.dart';

/// Screen daftar notifikasi dengan tab filter: Semua / Belum Dibaca / Riwayat.
/// Support pull-to-refresh, mark as read (single & all), dan navigasi ke
/// halaman terkait berdasarkan `kategori` notifikasi + `idRequest`.
///
/// PENTING: backend (list.php) tidak pernah mengirim field `link` — jadi
/// navigasi dibangun di sisi app lewat `_routeFor()`. Sesuaikan nama route
/// di bawah dengan route yang sudah kamu daftarkan di MaterialApp.
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen>
    with SingleTickerProviderStateMixin {
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

  static const _tabs = ['semua', 'belum_dibaca', 'riwayat'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    for (final filter in _tabs) {
      _loadData(filter);
    }
  }

  @override
  void dispose() {
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

  /// Tentukan route tujuan berdasarkan kategori notifikasi.
  /// Sesuaikan nama route ini dengan yang terdaftar di MaterialApp kamu.
  String? _routeFor(NotifikasiModel item) {
    if (item.idRequest == null) return null;
    switch (item.kategori) {
      case 'penugasan':
        return '/penugasan/detail';
      case 'laporan':
        return '/laporan/form';
      default:
        return null;
    }
  }

  Future<void> _handleTap(NotifikasiModel item) async {
    if (!item.isRead) {
      try {
        await NotifikasiService.markRead(item.id);
        await _refreshAll();
      } catch (_) {
        // Diamkan — navigasi tetap lanjut walau mark read gagal.
      }
    }

    final route = _routeFor(item);
    if (route != null && mounted) {
      try {
        await Navigator.pushNamed(
          context,
          route,
          arguments: {'id_request': item.idRequest},
        );
      } catch (_) {
        // Route belum terdaftar — abaikan saja, jangan crash.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Belum Dibaca'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map(_buildTabBody).toList(),
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadData(filter),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _NotifikasiCard(
          item: items[index],
          onTap: () => _handleTap(items[index]),
        ),
      ),
    );
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

class _NotifikasiCard extends StatelessWidget {
  final NotifikasiModel item;
  final VoidCallback onTap;

  const _NotifikasiCard({required this.item, required this.onTap});

  IconData get _icon {
    switch (item.kategori) {
      case 'request':
        return Icons.assignment_outlined;
      case 'pembayaran':
        return Icons.payments_outlined;
      case 'sistem':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

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
              color: unread ? AppColors.primary.withOpacity(0.25) : AppColors.backgroundAlt,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unread
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.backgroundAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  size: 20,
                  color: unread ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.judul,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
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
                    const SizedBox(height: 6),
                    Text(
                      _formatWaktu(item.createdAt),
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}