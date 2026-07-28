import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _KegiatanScreenState
    extends State<KegiatanScreen> {
  late Future<List<KegiatanModel>> _future;

  final TextEditingController _searchController =
      TextEditingController();

  int? _userId;

  @override
  void initState() {
    super.initState();

    _future = KegiatanService.getList();

    _loadUserId();

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
  // AMBIL ID DRIVER YANG SEDANG LOGIN
  // =========================================================================

  Future<void> _loadUserId() async {
    final prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _userId = prefs.getInt('user_id');
    });
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
  // FILTER SEARCH
  // =========================================================================

  List<KegiatanModel> _filterList(
    List<KegiatanModel> list,
  ) {
    final keyword =
        _searchController.text
            .trim()
            .toLowerCase();

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
  // FORMAT TANGGAL
  // =========================================================================

  String _formatTanggal(
    String tanggal,
  ) {
    if (tanggal.isEmpty) {
      return '-';
    }

    try {
      final date =
          DateTime.parse(tanggal);

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

  String _formatJam(
    String jam,
  ) {
    if (jam.isEmpty) {
      return '-';
    }

    if (jam.length >= 5) {
      return jam.substring(0, 5);
    }

    return jam;
  }

  // =========================================================================
  // CEK APAKAH TUGAS MILIK DRIVER LOGIN
  // =========================================================================

  bool _isTugasAnda(
    KegiatanModel kegiatan,
  ) {
    if (_userId == null) {
      return false;
    }

    return kegiatan.idDriver == _userId;
  }

  // =========================================================================
  // PILIH / AMBIL KEGIATAN
  // =========================================================================

  Future<void> _ambilKegiatan(
    KegiatanModel kegiatan,
  ) async {
    try {
      _showLoading();

      await KegiatanService.ambilKegiatan(
        kegiatan.id,
      );

      if (mounted) {
        Navigator.pop(context);
      }

      _reload();

      if (mounted) {
        _showSuccess(
          'Kegiatan berhasil diambil',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        _showError(
          e.toString(),
        );
      }
    }
  }

  // =========================================================================
  // KONFIRMASI PILIH KEGIATAN
  // =========================================================================

  Future<void> _konfirmasiAmbil(
    KegiatanModel kegiatan,
  ) async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          title: const Text(
            'Pilih Kegiatan',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin mengambil kegiatan ini sebagai tugas Anda?',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  false,
                );
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Ya, Pilih',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _ambilKegiatan(
        kegiatan,
      );
    }
  }

  // =========================================================================
  // KONFIRMASI BATALKAN
  // =========================================================================

  Future<void> _konfirmasiBatalkan(
    KegiatanModel kegiatan,
  ) async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          title: const Text(
            'Batalkan Tugas?',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan pengambilan kegiatan ini?',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  false,
                );
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
                Navigator.pop(
                  ctx,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.danger,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _batalkanKegiatan(
        kegiatan,
      );
    }
  }

  // =========================================================================
  // BATALKAN KEGIATAN
  // =========================================================================

  Future<void> _batalkanKegiatan(
    KegiatanModel kegiatan,
  ) async {
    try {
      _showLoading();

      await KegiatanService
          .batalkanKegiatan(
        kegiatan.id,
      );

      if (mounted) {
        Navigator.pop(context);
      }

      _reload();

      if (mounted) {
        _showSuccess(
          'Pengambilan kegiatan berhasil dibatalkan',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        _showError(
          e.toString(),
        );
      }
    }
  }

  // =========================================================================
  // LOADING
  // =========================================================================

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child:
              CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      },
    );
  }

  // =========================================================================
  // SUCCESS MESSAGE
  // =========================================================================

  void _showSuccess(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor:
            Colors.green,
      ),
    );
  }

  // =========================================================================
  // ERROR MESSAGE
  // =========================================================================

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor:
            AppColors.danger,
      ),
    );
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  RefreshIndicator(
                color:
                    AppColors.primary,

                onRefresh: () async {
                  _reload();
                  await _future;
                },

                child:
                    FutureBuilder<
                        List<KegiatanModel>>(
                  future: _future,

                  builder: (
                    context,
                    snapshot,
                  ) {
                    // =======================================================
                    // LOADING
                    // =======================================================

                    if (snapshot
                            .connectionState ==
                        ConnectionState
                            .waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              AppColors.primary,
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
                        _filterList(
                      originalList,
                    );

                    return ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),

                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        24,
                      ),

                      children: [
                        // ===================================================
                        // HEADER
                        // ===================================================

                        const Text(
                          'Kegiatan Harian',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                AppColors.primary,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        const Text(
                          'Daftar agenda kegiatan harian operasional PLN',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                AppColors.textBody,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ===================================================
                        // SEARCH
                        // ===================================================

                        Container(
                          height: 40,

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        8),
                            border:
                                Border.all(
                              color: Colors
                                  .grey
                                  .shade300,
                            ),
                          ),

                          child:
                              TextField(
                            controller:
                                _searchController,

                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors
                                      .textPrimary,
                            ),

                            decoration:
                                InputDecoration(
                              hintText:
                                  'Cari kegiatan atau tujuan...',

                              hintStyle:
                                  const TextStyle(
                                fontSize: 10,
                                color:
                                    AppColors
                                        .textMuted,
                              ),

                              prefixIcon:
                                  const Icon(
                                Icons.search,
                                size: 18,
                                color:
                                    AppColors
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
                                                16,
                                          ),
                                        )
                                      : null,

                              border:
                                  InputBorder
                                      .none,

                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // ===================================================
                        // LIST
                        // ===================================================

                        if (list.isEmpty)
                          _buildEmptyState()
                        else
                          ...list.map(
                            (
                              kegiatan,
                            ) =>
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
    final tugasAnda =
        _isTugasAnda(k);

    final sudahDiambil =
        k.idDriver != null;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        border:
            Border.all(
          color:
              Colors.grey.shade300,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(
                        0.03),
            blurRadius: 5,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ===============================================================
          // JUDUL + STATUS
          // ===============================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  k.namaKegiatan,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 12,
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

              _buildStatus(
                k,
                tugasAnda,
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          // ===============================================================
          // TUJUAN
          // ===============================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Icon(
                Icons
                    .location_on_outlined,
                size: 14,
                color:
                    AppColors.textMuted,
              ),

              const SizedBox(
                width: 5,
              ),

              Expanded(
                child: Text(
                  k.tujuan,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 9,
                    color:
                        AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 9,
          ),

          // ===============================================================
          // TANGGAL + JAM
          // ===============================================================

          Row(
            children: [
              const Icon(
                Icons
                    .calendar_today_outlined,
                size: 13,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 5,
              ),

              Text(
                _formatTanggal(
                  k.tanggal,
                ),
                style:
                    const TextStyle(
                  fontSize: 9,
                  color:
                      AppColors.textBody,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              const Icon(
                Icons
                    .access_time_outlined,
                size: 13,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 5,
              ),

              Text(
                '${_formatJam(k.jam)} WIB',
                style:
                    const TextStyle(
                  fontSize: 9,
                  color:
                      AppColors.textBody,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          // ===============================================================
          // INFO DRIVER
          // ===============================================================

          _buildDriverInfo(
            k,
            tugasAnda,
          ),

          const SizedBox(
            height: 10,
          ),

          // ===============================================================
          // ACTION
          // ===============================================================

          _buildActionButtons(
            k,
            tugasAnda,
            sudahDiambil,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // DRIVER INFO
  // =========================================================================

  Widget _buildDriverInfo(
    KegiatanModel k,
    bool tugasAnda,
  ) {
    if (tugasAnda) {
      return Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 8,
        ),

        decoration:
            BoxDecoration(
          color: AppColors.primary
              .withOpacity(0.06),

          borderRadius:
              BorderRadius.circular(
                  7),
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

              child:
                  const Icon(
                Icons
                    .person_outline,
                size: 17,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            const Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'TUGAS ANDA',
                  style:
                      TextStyle(
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors
                            .textPrimary,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'Kegiatan ini menjadi tugas Anda',
                  style:
                      TextStyle(
                    fontSize: 7,
                    color:
                        AppColors
                            .textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (k.idDriver != null) {
      return Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 8,
        ),

        decoration:
            BoxDecoration(
          color: Colors.grey
              .withOpacity(0.06),

          borderRadius:
              BorderRadius.circular(
                  7),
        ),

        child: Row(
          children: [
            const Icon(
              Icons
                  .person_off_outlined,
              size: 20,
              color:
                  AppColors.textMuted,
            ),

            const SizedBox(
              width: 8,
            ),

            const Text(
              'Kegiatan sudah diambil driver lain',
              style: TextStyle(
                fontSize: 8,
                color:
                    AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(
        color: Colors.orange
            .withOpacity(0.06),

        borderRadius:
            BorderRadius.circular(
                7),
      ),

      child: const Row(
        children: [
          Icon(
            Icons
                .person_outline,
            size: 20,
            color:
                Colors.orange,
          ),

          SizedBox(
            width: 8,
          ),

          Text(
            'Belum ada driver yang mengambil kegiatan',
            style: TextStyle(
              fontSize: 8,
              color:
                  AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // STATUS
  // =========================================================================

  Widget _buildStatus(
    KegiatanModel k,
    bool tugasAnda,
  ) {
    String label;
    Color color;

    if (tugasAnda) {
      label = 'TUGAS ANDA';
      color = Colors.green;
    } else if (k.idDriver != null) {
      label = 'DIAMBIL DRIVER LAIN';
      color = Colors.grey;
    } else {
      label = 'BELUM DIAMBIL';
      color = Colors.orange;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
                0.08),

        borderRadius:
            BorderRadius.circular(
                10),

        border:
            Border.all(
          color:
              color.withOpacity(
                  0.3),
        ),
      ),

      child: Text(
        label,

        style:
            TextStyle(
          fontSize: 6,
          fontWeight:
              FontWeight.w700,
          color:
              color,
        ),
      ),
    );
  }

  // =========================================================================
  // ACTION BUTTONS
  // =========================================================================

  Widget _buildActionButtons(
    KegiatanModel k,
    bool tugasAnda,
    bool sudahDiambil,
  ) {
    // ===============================================================
    // TUGAS ANDA
    // ===============================================================

    if (tugasAnda) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 30,

              child:
                  OutlinedButton.icon(
                onPressed: () {
                  _showSuccess(
                    'Kegiatan ini sudah menjadi tugas Anda',
                  );
                },

                icon:
                    const Icon(
                  Icons
                      .check_circle_outline,
                  size: 13,
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
                    OutlinedButton
                        .styleFrom(
                  foregroundColor:
                      AppColors
                          .primary,

                  backgroundColor:
                      AppColors
                          .primary
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

          Expanded(
            child: SizedBox(
              height: 30,

              child:
                  OutlinedButton.icon(
                onPressed: () {
                  _konfirmasiBatalkan(
                    k,
                  );
                },

                icon:
                    const Icon(
                  Icons.close,
                  size: 12,
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
                    OutlinedButton
                        .styleFrom(
                  foregroundColor:
                      AppColors
                          .danger,

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
      );
    }

    // ===============================================================
    // KEGIATAN SUDAH DIAMBIL DRIVER LAIN
    // ===============================================================

    if (sudahDiambil) {
      return SizedBox(
        width:
            double.infinity,

        height: 30,

        child:
            OutlinedButton.icon(
          onPressed: null,

          icon:
              const Icon(
            Icons
                .lock_outline,
            size: 13,
          ),

          label:
              const Text(
            'Diambil Driver Lain',
            style:
                TextStyle(
              fontSize: 8,
            ),
          ),

          style:
              OutlinedButton
                  .styleFrom(
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
      );
    }

    // ===============================================================
    // BELUM DIAMBIL
    // ===============================================================

    return SizedBox(
      width:
          double.infinity,

      height: 30,

      child:
          ElevatedButton.icon(
        onPressed: () {
          _konfirmasiAmbil(
            k,
          );
        },

        icon:
            const Icon(
          Icons
              .add_task,
          size: 13,
        ),

        label:
            const Text(
          'Pilih Kegiatan',
          style:
              TextStyle(
            fontSize: 8,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        style:
            ElevatedButton
                .styleFrom(
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
                BorderRadius
                    .circular(
                        5),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // EMPTY STATE
  // =========================================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 70,
      ),

      child: Column(
        children: [
          Icon(
            Icons
                .event_note_outlined,
            size: 42,
            color: AppColors
                .textMuted
                .withOpacity(
                    0.5),
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'Belum ada kegiatan',
            style:
                TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors
                      .textPrimary,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'Belum ada kegiatan yang tersedia saat ini.',
            style:
                TextStyle(
              fontSize: 9,
              color:
                  AppColors
                      .textMuted,
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
            const EdgeInsets.all(
                24),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons
                  .error_outline,
              size: 40,
              color: AppColors
                  .danger
                  .withOpacity(
                      0.7),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Gagal memuat kegiatan',
              style:
                  TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors
                        .textPrimary,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Periksa koneksi internet Anda.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 9,
                color:
                    AppColors
                        .textMuted,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 32,

              child:
                  ElevatedButton(
                onPressed:
                    _reload,

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors
                          .primary,

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