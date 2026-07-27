import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/kegiatan_model.dart';
import '../../services/kegiatan_service.dart';

class DetailKegiatanScreen extends StatefulWidget {
  final int kegiatanId;

  const DetailKegiatanScreen({
    super.key,
    required this.kegiatanId,
  });

  @override
  State<DetailKegiatanScreen> createState() =>
      _DetailKegiatanScreenState();
}

class _DetailKegiatanScreenState
    extends State<DetailKegiatanScreen> {
  late Future<KegiatanModel> _future;

  @override
  void initState() {
    super.initState();

    _future = KegiatanService.getDetail(
      widget.kegiatanId,
    );
  }

  // =========================================================================
  // REFRESH DATA
  // =========================================================================

  Future<void> _reload() async {
    setState(() {
      _future = KegiatanService.getDetail(
        widget.kegiatanId,
      );
    });

    await _future;
  }

  // =========================================================================
  // FORMAT TANGGAL
  // =========================================================================

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

  // =========================================================================
  // FORMAT JAM
  // =========================================================================

  String _formatJam(String jam) {
    if (jam.isEmpty) return '-';

    if (jam.length >= 5) {
      return '${jam.substring(0, 5)} WIB';
    }

    return '$jam WIB';
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // =======================================================================
      // APP BAR
      // =======================================================================

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.primary,
          ),
        ),

        title: const Text(
          'Detail Kegiatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),

      // =======================================================================
      // BODY
      // =======================================================================

      body: FutureBuilder<KegiatanModel>(
        future: _future,

        builder: (context, snapshot) {
          // ===================================================================
          // LOADING
          // ===================================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ===================================================================
          // ERROR
          // ===================================================================

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          // ===================================================================
          // DATA KOSONG
          // ===================================================================

          if (!snapshot.hasData) {
            return _buildEmptyState();
          }

          final kegiatan = snapshot.data!;

          // ===================================================================
          // DETAIL
          // ===================================================================

          return RefreshIndicator(
            onRefresh: _reload,
            color: AppColors.primary,

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ),

              children: [
                // =============================================================
                // HEADER CARD
                // =============================================================

                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.025),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =======================================================
                      // ICON
                      // =======================================================

                      Container(
                        width: 44,
                        height: 44,

                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withOpacity(0.08),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),

                        child: const Icon(
                          Icons.event_note_outlined,
                          color: AppColors.primary,
                          size: 23,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // =======================================================
                      // NAMA KEGIATAN
                      // =======================================================

                      Text(
                        kegiatan.namaKegiatan,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Detail informasi kegiatan harian',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // =============================================================
                // INFORMASI KEGIATAN
                // =============================================================

                Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Informasi Kegiatan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // =======================================================
                      // TUJUAN
                      // =======================================================

                      _buildInfoItem(
                        icon:
                            Icons.location_on_outlined,
                        label: 'Tujuan',
                        value: kegiatan.tujuan,
                      ),

                      const SizedBox(height: 14),

                      // =======================================================
                      // TANGGAL
                      // =======================================================

                      _buildInfoItem(
                        icon:
                            Icons.calendar_today_outlined,
                        label: 'Tanggal',
                        value: _formatTanggal(
                          kegiatan.tanggal,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // =======================================================
                      // JAM
                      // =======================================================

                      _buildInfoItem(
                        icon:
                            Icons.access_time_outlined,
                        label: 'Waktu',
                        value: _formatJam(
                          kegiatan.jam,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // INFO ITEM
  // =========================================================================

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color: AppColors.primary
                .withOpacity(0.07),
            borderRadius:
                BorderRadius.circular(8),
          ),

          child: Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // EMPTY STATE
  // =========================================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.event_note_outlined,
              size: 48,
              color:
                  AppColors.textMuted.withOpacity(0.5),
            ),

            const SizedBox(height: 12),

            const Text(
              'Kegiatan Tidak Ditemukan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Data kegiatan yang kamu cari tidak tersedia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ERROR STATE
  // =========================================================================

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline,
              size: 45,
              color: AppColors.danger,
            ),

            const SizedBox(height: 12),

            const Text(
              'Gagal Memuat Detail Kegiatan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              error.replaceFirst(
                'ApiException: ',
                '',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 14),

            OutlinedButton(
              onPressed: _reload,

              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}