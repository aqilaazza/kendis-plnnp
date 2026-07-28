import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../models/kegiatan_model.dart';
import '../../services/kegiatan_service.dart';

class KegiatanScreen extends StatefulWidget {
  const KegiatanScreen({
    super.key,
  });

  @override
  State<KegiatanScreen> createState() =>
      _KegiatanScreenState();
}

class _KegiatanScreenState extends State<KegiatanScreen> {
  late Future<List<KegiatanModel>> _future;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _future = KegiatanService.getList();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================================
  // RELOAD
  // =========================================================================

  Future<void> _reload() async {
    setState(() {
      _future = KegiatanService.getList();
    });

    await _future;
  }

  // =========================================================================
  // FILTER SEARCH
  // =========================================================================

  List<KegiatanModel> _filterList(
    List<KegiatanModel> list,
  ) {
    final keyword =
        _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      return list;
    }

    return list.where((kegiatan) {
      return kegiatan.namaKegiatan
              .toLowerCase()
              .contains(keyword) ||
          kegiatan.tujuan
              .toLowerCase()
              .contains(keyword);
    }).toList();
  }

  // =========================================================================
  // FORMAT TANGGAL
  // =========================================================================

  String _formatTanggal(String tanggal) {
    if (tanggal.isEmpty) {
      return '-';
    }

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
    if (jam.isEmpty) {
      return '-';
    }

    if (jam.length >= 5) {
      return jam.substring(0, 5);
    }

    return jam;
  }

  // =========================================================================
  // FILTER BUTTON
  // =========================================================================

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Kegiatan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              _filterOption(
                icon: Icons.list_alt_outlined,
                label: 'Semua Kegiatan',
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),

              _filterOption(
                icon: Icons.check_circle_outline,
                label: 'Kegiatan Aktif',
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),

              _filterOption(
                icon: Icons.history,
                label: 'Riwayat Kegiatan',
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: AppColors.primary,
            ),

            const SizedBox(width: 12),

            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TUGAS ANDA
  // =========================================================================

  void _tugasAnda() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Kegiatan ini merupakan tugas Anda.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // =========================================================================
  // BATALKAN
  // =========================================================================

  void _batalkanKegiatan(
    KegiatanModel kegiatan,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Batalkan Tugas?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          content: const Text(
            'Apakah kamu yakin ingin membatalkan tugas kegiatan ini?',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textBody,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text(
                'Tidak',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur pembatalan akan dihubungkan ke API.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Batalkan',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // HEADER
            // =================================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                12,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ===========================================================
                  // TITLE
                  // ===========================================================

                  const Text(
                    'Kegiatan Harian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Daftar agenda kegiatan harian operasional PLN',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textBody,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ===========================================================
                  // SEARCH + FILTER
                  // ===========================================================

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 38,

                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                            border: Border.all(
                              color:
                                  Colors.grey.shade300,
                            ),
                          ),

                          child: TextField(
                            controller:
                                _searchController,

                            style:
                                const TextStyle(
                              fontSize: 10,
                              color:
                                  AppColors.textPrimary,
                            ),

                            decoration:
                                InputDecoration(
                              hintText:
                                  'Cari kegiatan atau tujuan...',

                              hintStyle:
                                  TextStyle(
                                fontSize: 9,
                                color:
                                    AppColors.textMuted,
                              ),

                              prefixIcon:
                                  const Icon(
                                Icons.search,
                                size: 17,
                                color:
                                    AppColors.textMuted,
                              ),

                              suffixIcon:
                                  _searchController
                                          .text
                                          .isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            _searchController
                                                .clear();
                                          },
                                          padding:
                                              EdgeInsets.zero,
                                          icon:
                                              const Icon(
                                            Icons.close,
                                            size: 15,
                                          ),
                                        )
                                      : null,

                              border:
                                  InputBorder.none,

                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // =======================================================
                      // FILTER
                      // =======================================================

                      InkWell(
                        onTap: _showFilter,
                        borderRadius:
                            BorderRadius.circular(8),

                        child: Container(
                          width: 38,
                          height: 38,

                          decoration:
                              BoxDecoration(
                            color: AppColors.primary
                                .withOpacity(0.08),

                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),

                            border: Border.all(
                              color: AppColors.primary
                                  .withOpacity(0.15),
                            ),
                          ),

                          child: const Icon(
                            Icons.filter_list,
                            size: 18,
                            color:
                                AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =================================================================
            // LIST
            // =================================================================

            Expanded(
              child: RefreshIndicator(
                onRefresh: _reload,

                color: AppColors.primary,

                child:
                    FutureBuilder<List<KegiatanModel>>(
                  future: _future,

                  builder: (
                    context,
                    snapshot,
                  ) {
                    // =========================================================
                    // LOADING
                    // =========================================================

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    // =========================================================
                    // ERROR
                    // =========================================================

                    if (snapshot.hasError) {
                      return _buildErrorState();
                    }

                    // =========================================================
                    // DATA
                    // =========================================================

                    final originalList =
                        snapshot.data ?? [];

                    final list =
                        _filterList(
                      originalList,
                    );

                    if (list.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),

                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        2,
                        16,
                        24,
                      ),

                      itemCount:
                          list.length,

                      itemBuilder:
                          (context, index) {
                        return _buildKegiatanCard(
                          list[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // KEGIATAN CARD
  // =========================================================================

  Widget _buildKegiatanCard(
    KegiatanModel kegiatan,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.all(
        10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =================================================================
          // NAMA KEGIATAN + STATUS
          // =================================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  kegiatan.namaKegiatan,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // STATUS AKTIF
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.blue
                      .withOpacity(0.10),

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  border: Border.all(
                    color: Colors.blue
                        .withOpacity(0.25),
                  ),
                ),

                child: const Text(
                  'AKTIF',
                  style: TextStyle(
                    fontSize: 6,
                    fontWeight:
                        FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // =================================================================
          // TUJUAN
          // =================================================================

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color:
                    AppColors.textMuted,
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  kegiatan.tujuan
                      .toUpperCase(),

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 8,
                    color:
                        AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // =================================================================
          // TANGGAL + JAM
          // =================================================================

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color:
                    AppColors.primary,
              ),

              const SizedBox(width: 4),

              Text(
                _formatTanggal(
                  kegiatan.tanggal,
                ),

                style:
                    const TextStyle(
                  fontSize: 8,
                  color:
                      AppColors.textBody,
                ),
              ),

              const SizedBox(width: 12),

              const Icon(
                Icons.access_time_outlined,
                size: 12,
                color:
                    AppColors.primary,
              ),

              const SizedBox(width: 4),

              Text(
                '${_formatJam(kegiatan.jam)} WIB',

                style:
                    const TextStyle(
                  fontSize: 8,
                  color:
                      AppColors.textBody,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          // =================================================================
          // DRIVER INFO
          // =================================================================

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 7,
            ),

            decoration:
                BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.07),

              borderRadius:
                  BorderRadius.circular(6),
            ),

            child: Row(
              children: [
                // ICON DRIVER
                Container(
                  width: 28,
                  height: 28,

                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,

                    color: AppColors.primary
                        .withOpacity(0.10),
                  ),

                  child: const Icon(
                    Icons.person_outline,
                    size: 16,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(width: 8),

                // DRIVER TEXT
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'DRIVER',
                      style:
                          TextStyle(
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'NID: DRIVER',
                      style:
                          TextStyle(
                        fontSize: 7,
                        color:
                            AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =================================================================
          // ACTION BUTTON
          // =================================================================

          Row(
            children: [
              // =============================================================
              // TUGAS ANDA
              // =============================================================

              Expanded(
                child: SizedBox(
                  height: 28,

                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _tugasAnda,

                    icon:
                        const Icon(
                      Icons
                          .check_circle_outline,
                      size: 12,
                    ),

                    label:
                        const Text(
                      'Tugas Anda',
                      style:
                          TextStyle(
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors.primary,

                      backgroundColor:
                          AppColors.primary
                              .withOpacity(
                            0.08,
                          ),

                      side:
                          BorderSide(
                        color: AppColors
                            .primary
                            .withOpacity(
                          0.25,
                        ),
                      ),

                      padding:
                          EdgeInsets.zero,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // =============================================================
              // BATALKAN
              // =============================================================

              Expanded(
                child: SizedBox(
                  height: 28,

                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _batalkanKegiatan(
                        kegiatan,
                      );
                    },

                    icon:
                        const Icon(
                      Icons.close,
                      size: 11,
                    ),

                    label:
                        const Text(
                      'Batalkan',
                      style:
                          TextStyle(
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors.danger,

                      backgroundColor:
                          Colors.white,

                      side:
                          BorderSide(
                        color: Colors
                            .grey
                            .shade300,
                      ),

                      padding:
                          EdgeInsets.zero,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // EMPTY STATE
  // =========================================================================

  Widget _buildEmptyState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      children: [
        const SizedBox(height: 100),

        Icon(
          Icons.event_note_outlined,
          size: 42,
          color: AppColors.textMuted
              .withOpacity(0.5),
        ),

        const SizedBox(height: 10),

        const Center(
          child: Text(
            'Belum ada kegiatan',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Center(
          child: Text(
            'Belum ada kegiatan yang tersedia saat ini.',
            style: TextStyle(
              fontSize: 9,
              color:
                  AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // ERROR STATE
  // =========================================================================

  Widget _buildErrorState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      children: [
        const SizedBox(height: 100),

        Icon(
          Icons.error_outline,
          size: 42,
          color: AppColors.danger
              .withOpacity(0.7),
        ),

        const SizedBox(height: 10),

        const Center(
          child: Text(
            'Gagal memuat kegiatan',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: SizedBox(
            height: 32,

            child: ElevatedButton(
              onPressed: _reload,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,

                foregroundColor:
                    Colors.white,

                elevation: 0,
              ),

              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}