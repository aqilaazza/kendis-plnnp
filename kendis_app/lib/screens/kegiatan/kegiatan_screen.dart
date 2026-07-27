import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/kegiatan_model.dart';
import '../../services/kegiatan_service.dart';
import 'detail_kegiatan_screen.dart';

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

  final TextEditingController _searchController =
      TextEditingController();

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

  void _reload() {
    setState(() {
      _future = KegiatanService.getList();
    });
  }

  // =========================================================================
  // FILTER KEGIATAN
  // =========================================================================

  List<KegiatanModel> _filterList(
    List<KegiatanModel> list,
  ) {
    final keyword =
        _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      return list;
    }

    return list.where((k) {
      return k.namaKegiatan
              .toLowerCase()
              .contains(keyword) ||
          k.tujuan
              .toLowerCase()
              .contains(keyword);
    }).toList();
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
  // AMBIL KEGIATAN
  // =========================================================================

  Future<void> _ambilKegiatan(
    KegiatanModel kegiatan,
  ) async {
    try {
      // -------------------------------------------------------------
      // LOADING
      // -------------------------------------------------------------

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
      );

      // -------------------------------------------------------------
      // PANGGIL API AMBIL KEGIATAN
      // -------------------------------------------------------------

      await KegiatanService.ambilKegiatan(
        kegiatan.id,
      );

      // -------------------------------------------------------------
      // TUTUP LOADING
      // -------------------------------------------------------------

      if (mounted) {
        Navigator.pop(context);
      }

      // -------------------------------------------------------------
      // RELOAD DATA
      // -------------------------------------------------------------

      _reload();

      // -------------------------------------------------------------
      // PESAN BERHASIL
      // -------------------------------------------------------------

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kegiatan berhasil diambil',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // -------------------------------------------------------------
      // TUTUP LOADING
      // -------------------------------------------------------------

      if (mounted) {
        Navigator.pop(context);
      }

      // -------------------------------------------------------------
      // PESAN ERROR
      // -------------------------------------------------------------

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // =========================================================================
  // KONFIRMASI BATALKAN KEGIATAN
  // =========================================================================

  Future<void> _konfirmasiBatalkan(
    KegiatanModel kegiatan,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Batalkan Kegiatan?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          content: const Text(
            'Apakah kamu yakin ingin membatalkan tugas kegiatan ini?',
            style: TextStyle(
              fontSize: 11,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text(
                'Tidak',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Batalkan',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await _batalkanKegiatan(kegiatan);
  }

  // =========================================================================
  // BATALKAN KEGIATAN
  // =========================================================================

  Future<void> _batalkanKegiatan(
    KegiatanModel kegiatan,
  ) async {
    try {
      // -------------------------------------------------------------
      // LOADING
      // -------------------------------------------------------------

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
      );

      // -------------------------------------------------------------
      // PANGGIL API BATALKAN
      // -------------------------------------------------------------

      await KegiatanService.batalkanKegiatan(
        kegiatan.id,
      );

      // -------------------------------------------------------------
      // TUTUP LOADING
      // -------------------------------------------------------------

      if (mounted) {
        Navigator.pop(context);
      }

      // -------------------------------------------------------------
      // RELOAD
      // -------------------------------------------------------------

      _reload();

      // -------------------------------------------------------------
      // PESAN BERHASIL
      // -------------------------------------------------------------

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kegiatan berhasil dibatalkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // -------------------------------------------------------------
      // TUTUP LOADING
      // -------------------------------------------------------------

      if (mounted) {
        Navigator.pop(context);
      }

      // -------------------------------------------------------------
      // PESAN ERROR
      // -------------------------------------------------------------

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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
            // ===============================================================
            // CONTENT
            // ===============================================================

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _reload();
                  await _future;
                },

                child: FutureBuilder<
                    List<KegiatanModel>>(
                  future: _future,

                  builder: (
                    context,
                    snapshot,
                  ) {
                    // =======================================================
                    // LOADING
                    // =======================================================

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

                    // =======================================================
                    // ERROR
                    // =======================================================

                    if (snapshot.hasError) {
                      return _buildErrorState();
                    }

                    // =======================================================
                    // DATA
                    // =======================================================

                    final originalList =
                        snapshot.data ?? [];

                    final list =
                        _filterList(originalList);

                    return ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),

                      padding:
                          const EdgeInsets.fromLTRB(
                        10,
                        8,
                        10,
                        24,
                      ),

                      children: [
                        // ===================================================
                        // PAGE TITLE
                        // ===================================================

                        const Text(
                          'Kegiatan Harian',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Daftar agenda kegiatan harian operasional PLN',
                          style: TextStyle(
                            fontSize: 9,
                            color:
                                AppColors.textBody,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===================================================
                        // SEARCH + FILTER
                        // ===================================================

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 34,

                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(6),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .grey
                                        .shade300,
                                  ),
                                ),

                                child: TextField(
                                  controller:
                                      _searchController,

                                  style:
                                      const TextStyle(
                                    fontSize: 9,
                                    color: AppColors
                                        .textPrimary,
                                  ),

                                  decoration:
                                      InputDecoration(
                                    hintText:
                                        'Cari kegiatan atau tujuan...',

                                    hintStyle:
                                        TextStyle(
                                      fontSize: 9,
                                      color: AppColors
                                          .textMuted,
                                    ),

                                    prefixIcon:
                                        const Icon(
                                      Icons.search,
                                      size: 17,
                                      color: AppColors
                                          .textMuted,
                                    ),

                                    suffixIcon:
                                        _searchController
                                                .text
                                                .isNotEmpty
                                            ? IconButton(
                                                onPressed:
                                                    () {
                                                  _searchController
                                                      .clear();
                                                },
                                                icon:
                                                    const Icon(
                                                  Icons
                                                      .close,
                                                  size:
                                                      15,
                                                ),
                                                padding:
                                                    EdgeInsets
                                                        .zero,
                                              )
                                            : null,

                                    border:
                                        InputBorder
                                            .none,

                                    contentPadding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 6,
                            ),

                            InkWell(
                              onTap: _showFilter,

                              borderRadius:
                                  BorderRadius
                                      .circular(6),

                              child: Container(
                                width: 34,
                                height: 34,

                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .primary
                                      .withOpacity(
                                          0.08),
                                  borderRadius:
                                      BorderRadius
                                          .circular(6),
                                  border:
                                      Border.all(
                                    color: AppColors
                                        .primary
                                        .withOpacity(
                                            0.15),
                                  ),
                                ),

                                child: const Icon(
                                  Icons.filter_list,
                                  size: 17,
                                  color: AppColors
                                      .primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ===================================================
                        // LIST KEGIATAN
                        // ===================================================

                        if (list.isEmpty)
                          _buildEmptyState()
                        else
                          ...list.map(
                            (kegiatan) =>
                                _buildKegiatanCard(
                              kegiatan,
                            ),
                          ),
                      ],
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
    KegiatanModel k,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        10,
        8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(9),

        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ================================================================
          // JUDUL + STATUS
          // ================================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  k.namaKegiatan,

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

              const SizedBox(
                width: 8,
              ),

              _buildStatus(k),
            ],
          ),

          const SizedBox(height: 5),

          // ================================================================
          // LOKASI / TUJUAN
          // ================================================================

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppColors.textMuted,
              ),

              const SizedBox(
                width: 3,
              ),

              Expanded(
                child: Text(
                  k.tujuan.toUpperCase(),

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 8,
                    color:
                        AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ================================================================
          // TANGGAL + JAM
          // ================================================================

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppColors.primary,
              ),

              const SizedBox(
                width: 4,
              ),

              Text(
                _formatTanggal(k.tanggal),

                style: const TextStyle(
                  fontSize: 8,
                  color:
                      AppColors.textBody,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Icon(
                Icons.access_time_outlined,
                size: 12,
                color: AppColors.primary,
              ),

              const SizedBox(
                width: 4,
              ),

              Text(
                '${_formatJam(k.jam)} WIB',

                style: const TextStyle(
                  fontSize: 8,
                  color:
                      AppColors.textBody,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          // ================================================================
          // DRIVER INFO
          // ================================================================

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),

            decoration:
                BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.06),

              borderRadius:
                  BorderRadius.circular(6),
            ),

            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,

                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,

                    color: AppColors
                        .primary
                        .withOpacity(
                            0.1),
                  ),

                  child: const Icon(
                    Icons.person_outline,
                    size: 17,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      k.sudahDiambil
                          ? 'TUGAS ANDA'
                          : 'DRIVER',

                      style:
                          const TextStyle(
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w700,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      k.sudahDiambil
                          ? 'Kegiatan sudah Anda ambil'
                          : 'Belum ada driver',

                      style:
                          const TextStyle(
                        fontSize: 7,
                        color: AppColors
                            .textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ================================================================
          // ACTION BUTTONS
          // ================================================================

          _buildActionButtons(k),
        ],
      ),
    );
  }

  // =========================================================================
  // STATUS
  // =========================================================================

  Widget _buildStatus(
    KegiatanModel k,
  ) {
    final sudahDiambil =
        k.sudahDiambil;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),

      decoration: BoxDecoration(
        color: sudahDiambil
            ? Colors.green
                .withOpacity(0.08)
            : Colors.orange
                .withOpacity(0.08),

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: sudahDiambil
              ? Colors.green
                  .withOpacity(0.35)
              : Colors.orange
                  .withOpacity(0.35),
        ),
      ),

      child: Text(
        sudahDiambil
            ? 'SUDAH DIAMBIL'
            : 'BELUM DIAMBIL',

        style: TextStyle(
          fontSize: 6,
          fontWeight:
              FontWeight.w700,

          color: sudahDiambil
              ? Colors.green
              : Colors.orange,
        ),
      ),
    );
  }

  // =========================================================================
  // ACTION BUTTONS
  // =========================================================================

  Widget _buildActionButtons(
    KegiatanModel k,
  ) {
    return Column(
      children: [
        // ==============================================================
        // JIKA BELUM DIAMBIL
        // ==============================================================

        if (!k.sudahDiambil)
          SizedBox(
            width: double.infinity,
            height: 28,

            child: ElevatedButton.icon(
              onPressed: () {
                _ambilKegiatan(k);
              },

              icon: const Icon(
                Icons.add_task,
                size: 13,
              ),

              label: const Text(
                'Pilih Kegiatan',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                foregroundColor:
                    Colors.white,

                backgroundColor:
                    AppColors.primary,

                elevation: 0,

                padding:
                    EdgeInsets.zero,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          5),
                ),
              ),
            ),
          ),

        // ==============================================================
        // JIKA SUDAH DIAMBIL
        // ==============================================================

        if (k.sudahDiambil)
          Row(
            children: [
              // =========================================================
              // TUGAS ANDA
              // =========================================================

              Expanded(
                child: SizedBox(
                  height: 28,

                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Kegiatan ini sudah menjadi tugas Anda',
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 12,
                    ),

                    label: const Text(
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
                                  0.06),

                      side:
                          BorderSide(
                        color: AppColors
                            .primary
                            .withOpacity(
                                0.25),
                      ),

                      padding:
                          EdgeInsets.zero,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 6,
              ),

              // =========================================================
              // BATALKAN
              // =========================================================

              Expanded(
                child: SizedBox(
                  height: 28,

                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _konfirmasiBatalkan(
                        k,
                      );
                    },

                    icon: const Icon(
                      Icons.close,
                      size: 11,
                    ),

                    label: const Text(
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
                          AppColors.danger
                              .withOpacity(
                                  0.02),

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
                                    5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(
          height: 6,
        ),

        // ==============================================================
        // LIHAT DETAIL KEGIATAN
        // ==============================================================

        SizedBox(
          width: double.infinity,
          height: 28,

          child:
              OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetailKegiatanScreen(
                    kegiatanId: k.id,
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.visibility_outlined,
              size: 13,
            ),

            label: const Text(
              'Lihat Detail Kegiatan',
              style: TextStyle(
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
                  Colors.white,

              side: BorderSide(
                color: AppColors
                    .primary
                    .withOpacity(0.25),
              ),

              padding:
                  EdgeInsets.zero,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                        5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // EMPTY STATE
  // =========================================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 70,
      ),

      child: Column(
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 40,
            color: AppColors.textMuted
                .withOpacity(0.5),
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'Belum ada kegiatan',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'Belum ada kegiatan yang tersedia saat ini.',

            style: TextStyle(
              fontSize: 9,
              color:
                  AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // ERROR STATE
  // =========================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.danger
                  .withOpacity(0.7),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Gagal memuat kegiatan',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 32,

              child:
                  ElevatedButton(
                onPressed: _reload,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,

                  foregroundColor:
                      Colors.white,

                  elevation: 0,
                ),

                child:
                    const Text(
                  'Coba Lagi',
                  style:
                      TextStyle(
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}