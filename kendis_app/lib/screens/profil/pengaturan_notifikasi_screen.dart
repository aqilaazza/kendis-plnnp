import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class PengaturanNotifikasiScreen extends StatefulWidget {
  const PengaturanNotifikasiScreen({super.key});

  @override
  State<PengaturanNotifikasiScreen> createState() =>
      _PengaturanNotifikasiScreenState();
}

class _PengaturanNotifikasiScreenState
    extends State<PengaturanNotifikasiScreen> {
  bool _notifikasiPenugasan = true;
  bool _perubahanStatus = true;
  bool _informasiPengumuman = true;
  bool _suaraNotifikasi = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // =============================================================
            // HEADER
            // =============================================================

            _buildHeader(context),

            // =============================================================
            // CONTENT
            // =============================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  24,
                  18,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =======================================================
                    // SECTION NOTIFIKASI
                    // =======================================================

                    _sectionLabel('NOTIFIKASI'),

                    const SizedBox(height: 8),

                    _buildSettingCard(
                      children: [
                        _buildNotificationTile(
                          icon: Icons.assignment_outlined,
                          title: 'Notifikasi Penugasan',
                          subtitle:
                              'Terima pemberitahuan saat mendapat penugasan baru',
                          value: _notifikasiPenugasan,
                          onChanged: (value) {
                            setState(() {
                              _notifikasiPenugasan = value;
                            });
                          },
                        ),

                        _buildDivider(),

                        _buildNotificationTile(
                          icon: Icons.sync_outlined,
                          title: 'Perubahan Status Tugas',
                          subtitle:
                              'Terima pemberitahuan saat status tugas berubah',
                          value: _perubahanStatus,
                          onChanged: (value) {
                            setState(() {
                              _perubahanStatus = value;
                            });
                          },
                        ),

                        _buildDivider(),

                        _buildNotificationTile(
                          icon: Icons.campaign_outlined,
                          title: 'Informasi & Pengumuman',
                          subtitle:
                              'Terima informasi dan pengumuman terbaru',
                          value: _informasiPengumuman,
                          onChanged: (value) {
                            setState(() {
                              _informasiPengumuman = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =======================================================
                    // SECTION PREFERENSI
                    // =======================================================

                    _sectionLabel('PREFERENSI'),

                    const SizedBox(height: 8),

                    _buildSettingCard(
                      children: [
                        _buildNotificationTile(
                          icon: Icons.volume_up_outlined,
                          title: 'Suara Notifikasi',
                          subtitle:
                              'Putar suara saat menerima notifikasi',
                          value: _suaraNotifikasi,
                          onChanged: (value) {
                            setState(() {
                              _suaraNotifikasi = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =======================================================
                    // INFO
                    // =======================================================

                    _buildInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HEADER
  // =========================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Pengaturan Notifikasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION LABEL
  // =========================================================================

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.6,
      ),
    );
  }

  // =========================================================================
  // SETTING CARD
  // =========================================================================

  Widget _buildSettingCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // =========================================================================
  // NOTIFICATION TILE
  // =========================================================================

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Row(
        children: [
          // ===============================================================
          // ICON
          // ===============================================================

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          // ===============================================================
          // TEXT
          // ===============================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ===============================================================
          // SWITCH
          // ===============================================================

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

  // =========================================================================
  // DIVIDER
  // =========================================================================

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 60,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
      ),
    );
  }

  // =========================================================================
  // INFO CARD
  // =========================================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 15,
            color: AppColors.primary,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Pengaturan notifikasi dapat diubah kapan saja sesuai kebutuhan Anda.',
              style: TextStyle(
                fontSize: 9,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}