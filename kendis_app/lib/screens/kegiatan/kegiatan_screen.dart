import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../../models/kegiatan_model.dart';
import '../../services/kegiatan_service.dart';
import '../../services/badge_notifier.dart';

class KegiatanScreen extends StatefulWidget {
  const KegiatanScreen({super.key});

  @override
  State<KegiatanScreen> createState() => _KegiatanScreenState();
}

class _KegiatanScreenState extends State<KegiatanScreen> {
  List<KegiatanModel> _kegiatanList = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadKegiatan();
    _loadUserId();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // DATA HELPERS
  // ---------------------------------------------------------------------

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _userId = prefs.getInt('user_id'));
  }

  // Spinner full-page hanya tampil kalau belum ada data sama sekali
  // (load pertama). Reload berikutnya (ambil/batalkan/refresh) tetap
  // menampilkan list lama sampai data baru datang, biar tidak "ngeblank".
  Future<void> _loadKegiatan() async {
    final isInitialLoad = _kegiatanList.isEmpty;
    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final list = await KegiatanService.getList();
      if (!mounted) return;
      setState(() {
        _kegiatanList = list;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      if (isInitialLoad == false) _showError('Gagal memuat data terbaru');
    }
  }

  Future<void> _reload() => _loadKegiatan();

  List<KegiatanModel> _filterList(List<KegiatanModel> list) {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return list;

    return list.where((k) {
      return k.namaKegiatan.toLowerCase().contains(keyword) ||
          k.tujuan.toLowerCase().contains(keyword);
    }).toList();
  }

  String _formatTanggal(String tanggal) {
    if (tanggal.isEmpty) return '-';
    try {
      final date = DateTime.parse(tanggal);
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}';
    } catch (_) {
      return tanggal;
    }
  }

  String _formatJam(String jam) {
    if (jam.isEmpty) return '-';
    return jam.length >= 5 ? jam.substring(0, 5) : jam;
  }

  bool _isTugasAnda(KegiatanModel kegiatan) =>
      _userId != null && kegiatan.idDriver == _userId;

  // ---------------------------------------------------------------------
  // AMBIL KEGIATAN
  // ---------------------------------------------------------------------

  Future<void> _ambilKegiatan(KegiatanModel kegiatan) async {
    try {
      _showLoading();
      await KegiatanService.ambilKegiatan(kegiatan.id);
      if (mounted) Navigator.pop(context); // tutup dialog loading
      _reload();
      BadgeNotifier.instance.refresh(); // <-- TAMBAHAN: badge Kegiatan langsung update
      if (mounted) {
        await _showStatusOverlay(
          icon: Icons.check_rounded,
          color: AppColors.primary,
          message: 'Kegiatan Berhasil Diambil',
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) _showError(e.toString());
    }
  }

  // Overlay full-layar berisi lingkaran icon besar + keterangan, muncul
  // sebentar lalu otomatis menutup diri sendiri kembali ke list (yang
  // sudah di-reload di belakang layar). Tidak perlu tombol atau halaman baru.
  Future<void> _showStatusOverlay({required IconData icon, required Color color, required String message}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => _StatusOverlay(icon: icon, color: color, message: message),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Future<void> _konfirmasiAmbil(KegiatanModel kegiatan) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 280,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON BADGE
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_task_outlined, size: 28, color: AppColors.primary),
              ),
              const SizedBox(height: 16),

              // TITLE
              const Text(
                'Pilih Kegiatan Ini?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              // MESSAGE
              Text(
                'Kegiatan ini akan menjadi tugas Anda. Pastikan Anda siap menjalankannya sesuai jadwal.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // TOMBOL YA, PILIH
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Ya, Pilih', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),

              // TOMBOL BATAL
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) await _ambilKegiatan(kegiatan);
  }

  // ---------------------------------------------------------------------
  // BATALKAN KEGIATAN
  // ---------------------------------------------------------------------

  Future<void> _batalkanKegiatan(KegiatanModel kegiatan) async {
    try {
      _showLoading();
      await KegiatanService.batalkanKegiatan(kegiatan.id);
      if (mounted) Navigator.pop(context); // tutup dialog loading
      _reload();
      BadgeNotifier.instance.refresh(); // <-- TAMBAHAN: badge Kegiatan langsung update
      if (mounted) {
        await _showStatusOverlay(
          icon: Icons.event_busy_rounded,
          color: AppColors.danger,
          message: 'Tugas Berhasil Dibatalkan',
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _konfirmasiBatalkan(KegiatanModel kegiatan) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 280,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON BADGE
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_busy_outlined, size: 28, color: AppColors.danger),
              ),
              const SizedBox(height: 16),

              // TITLE
              const Text(
                'Batalkan Tugas?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              // MESSAGE
              Text(
                'Kegiatan ini akan dilepas dan bisa diambil kembali oleh driver lain. Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // TOMBOL YA, BATALKAN
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Ya, Batalkan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),

              // TOMBOL TIDAK
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tidak', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) await _batalkanKegiatan(kegiatan);
  }

  // ---------------------------------------------------------------------
  // FEEDBACK HELPERS
  // ---------------------------------------------------------------------

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  // ---------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          const Text('Kegiatan Harian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Spacer(),
          InkWell(
            onTap: () {
              // TODO: Buka halaman notifikasi
            },
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.notifications_none_outlined, size: 22, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // BODY
  // ---------------------------------------------------------------------

  Widget _buildBody() {
    // Spinner full-page hanya untuk load pertama kali (belum ada data
    // sama sekali). Sesudah itu, reload (ambil/batalkan/pull-to-refresh)
    // tetap menampilkan list yang ada sampai data baru datang.
    if (_isLoading && _kegiatanList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_hasError && _kegiatanList.isEmpty) return _buildErrorState();

    final list = _filterList(_kegiatanList);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Daftar agenda kegiatan harian operasional PLN',
            style: TextStyle(fontSize: 13, color: AppColors.textBody),
          ),
          const SizedBox(height: 16),

          _buildSearchField(),
          const SizedBox(height: 16),

          if (list.isEmpty)
            _buildEmptyState()
          else
            ...list.map(_buildKegiatanCard),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari kegiatan atau tujuan...',
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
    );
  }

  // ---------------------------------------------------------------------
  // KEGIATAN CARD
  // ---------------------------------------------------------------------

  Widget _buildKegiatanCard(KegiatanModel k) {
    final tugasAnda = _isTugasAnda(k);
    final sudahDiambil = k.idDriver != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  k.namaKegiatan,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatus(k, tugasAnda),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  k.tujuan,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textBody),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(_formatTanggal(k.tanggal),
                  style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('${_formatJam(k.jam)} WIB',
                  style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
            ],
          ),
          const SizedBox(height: 12),

          _buildDriverInfo(k, tugasAnda),
          const SizedBox(height: 12),

          _buildActionButtons(k, tugasAnda, sudahDiambil),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(KegiatanModel k, bool tugasAnda) {
    if (tugasAnda) {
      return _driverInfoBox(
        color: AppColors.primary,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: const Icon(Icons.person_outline, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TUGAS ANDA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Kegiatan ini menjadi tugas Anda',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (k.idDriver != null) {
      return _driverInfoBox(
        color: Colors.grey,
        child: Row(
          children: [
            const Icon(Icons.person_off_outlined, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Kegiatan sudah diambil driver lain',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          ],
        ),
      );
    }

    return _driverInfoBox(
      color: Colors.orange,
      child: const Row(
        children: [
          Icon(Icons.person_outline, size: 20, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text('Belum ada driver yang mengambil kegiatan',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _driverInfoBox({required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _buildStatus(KegiatanModel k, bool tugasAnda) {
    final (label, color) = tugasAnda
        ? ('TUGAS ANDA', Colors.green)
        : k.idDriver != null
            ? ('DIAMBIL DRIVER LAIN', Colors.grey)
            : ('BELUM DIAMBIL', Colors.orange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildActionButtons(KegiatanModel k, bool tugasAnda, bool sudahDiambil) {
    final radius = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

    if (tugasAnda) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _showSuccess('Kegiatan ini sudah menjadi tugas Anda'),
                icon: const Icon(Icons.check_circle_outline, size: 17),
                label: const Text('Tugas Anda',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.06),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
                  padding: EdgeInsets.zero,
                  shape: radius,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _konfirmasiBatalkan(k),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Batalkan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: EdgeInsets.zero,
                  shape: radius,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (sudahDiambil) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.lock_outline, size: 17),
          label: const Text('Diambil Driver Lain', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: radius),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => _konfirmasiAmbil(k),
        icon: const Icon(Icons.add_task, size: 17),
        label: const Text('Pilih Kegiatan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: radius,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // EMPTY / ERROR STATE
  // ---------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(Icons.event_note_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Belum ada kegiatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Belum ada kegiatan yang tersedia saat ini.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.danger.withOpacity(0.7)),
            const SizedBox(height: 12),
            const Text('Gagal memuat kegiatan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Periksa koneksi internet Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _reload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Coba Lagi', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// STATUS OVERLAY
// Lingkaran icon besar + keterangan singkat, muncul sebentar lalu menutup
// dirinya sendiri. Dipakai sesudah ambil/batalkan kegiatan berhasil —
// tidak perlu tombol/interaksi apa pun. Warna & icon menyesuaikan aksi.
// =============================================================================

class _StatusOverlay extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _StatusOverlay({required this.icon, required this.color, required this.message});

  @override
  State<_StatusOverlay> createState() => _StatusOverlayState();
}

class _StatusOverlayState extends State<_StatusOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();

    // Auto-close sesudah sempat kebaca user, lalu balik ke list di belakangnya.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: widget.color.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Icon(widget.icon, size: 42, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.message,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}