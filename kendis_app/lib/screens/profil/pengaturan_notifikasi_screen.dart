import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/pengaturan_notifikasi_service.dart';

class PengaturanNotifikasiScreen extends StatefulWidget {
  const PengaturanNotifikasiScreen({super.key});

  @override
  State<PengaturanNotifikasiScreen> createState() => _PengaturanNotifikasiScreenState();
}

class _PengaturanNotifikasiScreenState extends State<PengaturanNotifikasiScreen> {
  PengaturanNotifikasiModel? _pengaturan;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPengaturan();
  }

  // ---------------------------------------------------------------------
  // LOAD DARI API
  // ---------------------------------------------------------------------

  Future<void> _loadPengaturan() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await PengaturanNotifikasiService.getPengaturan();
      if (!mounted) return;
      setState(() {
        _pengaturan = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ---------------------------------------------------------------------
  // UPDATE SATU TOGGLE + KIRIM KE API
  // ---------------------------------------------------------------------

  // UI langsung berubah duluan (optimistic update) biar switch terasa
  // responsif. Kalau ternyata gagal kirim ke server, toggle dibalikin
  // lagi ke nilai semula dan tampilkan pesan error.
  Future<void> _updateSetting(PengaturanNotifikasiModel updated) async {
    final previous = _pengaturan;
    setState(() => _pengaturan = updated);

    try {
      await PengaturanNotifikasiService.simpanPengaturan(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() => _pengaturan = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan pengaturan. Coba lagi.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(context),

            // CONTENT
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // BODY (LOADING / ERROR / KONTEN)
  // ===================================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_hasError || _pengaturan == null) {
      return _buildErrorState();
    }

    final pengaturan = _pengaturan!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECTION NOTIFIKASI
          _sectionLabel('NOTIFIKASI'),
          const SizedBox(height: 8),
          _buildSettingCard(children: [
            _buildNotificationTile(
              icon: Icons.assignment_outlined,
              title: 'Notifikasi Penugasan',
              subtitle: 'Terima pemberitahuan saat mendapat penugasan baru',
              value: pengaturan.notifikasiPenugasan,
              onChanged: (value) => _updateSetting(pengaturan.copyWith(notifikasiPenugasan: value)),
            ),
            _buildDivider(),
            _buildNotificationTile(
              icon: Icons.sync_outlined,
              title: 'Perubahan Status Tugas',
              subtitle: 'Terima pemberitahuan saat status tugas berubah',
              value: pengaturan.perubahanStatus,
              onChanged: (value) => _updateSetting(pengaturan.copyWith(perubahanStatus: value)),
            ),
            _buildDivider(),
            _buildNotificationTile(
              icon: Icons.campaign_outlined,
              title: 'Informasi & Pengumuman',
              subtitle: 'Terima informasi dan pengumuman terbaru',
              value: pengaturan.informasiPengumuman,
              onChanged: (value) => _updateSetting(pengaturan.copyWith(informasiPengumuman: value)),
            ),
          ]),
          const SizedBox(height: 24),

          // SECTION PREFERENSI
          _sectionLabel('PREFERENSI'),
          const SizedBox(height: 8),
          _buildSettingCard(children: [
            _buildNotificationTile(
              icon: Icons.volume_up_outlined,
              title: 'Suara Notifikasi',
              subtitle: 'Putar suara saat menerima notifikasi',
              value: pengaturan.suaraNotifikasi,
              onChanged: (value) => _updateSetting(pengaturan.copyWith(suaraNotifikasi: value)),
            ),
          ]),
          const SizedBox(height: 24),

          // INFO
          _buildInfoCard(),
        ],
      ),
    );
  }

  // ===================================================================
  // HEADER
  // ===================================================================

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
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back, size: 22, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Pengaturan Notifikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // SECTION LABEL
  // ===================================================================

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.6),
    );
  }

  // ===================================================================
  // SETTING CARD
  // ===================================================================

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ===================================================================
  // NOTIFICATION TILE
  // ===================================================================

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // ICON
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // SWITCH
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // DIVIDER
  // ===================================================================

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 66),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
    );
  }

  // ===================================================================
  // INFO CARD
  // ===================================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pengaturan notifikasi dapat diubah kapan saja sesuai kebutuhan Anda.',
              style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // ERROR STATE
  // ===================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.danger.withOpacity(0.7)),
            const SizedBox(height: 12),
            const Text('Gagal memuat pengaturan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Periksa koneksi internet Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _loadPengaturan,
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