import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../config/app_config.dart';
import '../../models/kendaraan_model.dart';
import '../../services/penugasan_service.dart';

/// Popup pilih kendaraan, dipanggil dari tombol "Mulai Perjalanan" di Detail
/// Penugasan kalau kendaraan untuk penugasan ini belum dipilih. Setelah
/// kendaraan dipilih & dikonfirmasi, endpoint pilih_kendaraan.php dipanggil —
/// ini sekaligus memulai perjalanan (gabung 1 aksi). Return true kalau
/// berhasil, supaya caller bisa reload data detail.
Future<bool> showPilihKendaraanDialog(BuildContext context, int idPenugasan) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _PilihKendaraanDialog(idPenugasan: idPenugasan),
  );
  return result ?? false;
}

class _PilihKendaraanDialog extends StatefulWidget {
  final int idPenugasan;
  const _PilihKendaraanDialog({required this.idPenugasan});

  @override
  State<_PilihKendaraanDialog> createState() => _PilihKendaraanDialogState();
}

class _PilihKendaraanDialogState extends State<_PilihKendaraanDialog> {
  late Future<List<KendaraanModel>> _future;
  int? _selectedId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = PenugasanService.getKendaraanTersedia();
  }

  Future<void> _confirmAndSubmit(KendaraanModel kendaraan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _KonfirmasiDialog(kendaraan: kendaraan),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _submitting = true);
    try {
      await PenugasanService.pilihKendaraan(idPenugasan: widget.idPenugasan, idKendaraan: kendaraan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${kendaraan.nopol} dipilih. Perjalanan dimulai, selamat bertugas!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.danger));
      // Kendaraan yang dipilih ternyata sudah tidak tersedia — refresh
      // daftar biar gak nawarin kendaraan yang sama.
      setState(() => _future = PenugasanService.getKendaraanTersedia());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: FutureBuilder<List<KendaraanModel>>(
          future: _future,
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            final selectedList = list.where((k) => k.id == _selectedId).toList();
            final selectedKendaraan = selectedList.isEmpty ? null : selectedList.first;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: const [
                      Icon(Icons.directions_car_filled_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Pilih Kendaraan & Mulai Perjalanan',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: Builder(builder: (context) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Gagal memuat: ${snapshot.error}'),
                      );
                    }
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Belum ada kendaraan yang tersedia saat ini.',
                            style: TextStyle(color: AppColors.textMuted)),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      children: [
                        for (final k in list)
                          _KendaraanCard(
                            kendaraan: k,
                            selected: k.id == _selectedId,
                            onTap: () => setState(() => _selectedId = k.id),
                          ),
                      ],
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: (_submitting || selectedKendaraan == null) ? null : () => _confirmAndSubmit(selectedKendaraan),
                          icon: _submitting
                              ? const SizedBox(
                                  width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.play_circle_outline, size: 18),
                          label: const Text('Pilih & Mulai Perjalanan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KendaraanCard extends StatelessWidget {
  final KendaraanModel kendaraan;
  final bool selected;
  final VoidCallback onTap;
  const _KendaraanCard({required this.kendaraan, required this.selected, required this.onTap});

  /// Foto disajikan lewat endpoint file.php di kendis_api sendiri (bukan
  /// ditebak path fisiknya) — supaya tetap benar walau lokasi folder
  /// uploads di server beda dari lokal, atau pas pindah hosting nanti.
  static String _fotoUrl(String foto) {
    if (foto.startsWith('http')) return foto;
    return '${AppConfig.baseUrl}/file.php?path=${Uri.encodeComponent(foto)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? AppColors.success : const Color(0xFFE8EDF2), width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFF0F3F7),
                        // NOTE: kolom `foto` di database sudah berupa path
                        // relatif LENGKAP dari root uploads, termasuk nama
                        // foldernya sendiri (contoh: "kendaraan/xxxx.webp").
                        // Folder fisiknya ada di www/kendis/uploads/... —
                        // beda dari folder API (kendis-plnnp/kendis_api) —
                        // jadi di sini ambil root domain-nya doang lalu
                        // gabung ke /kendis/uploads/, bukan nempel ke
                        // AppConfig.baseUrl secara langsung.
                        child: (kendaraan.foto == null || kendaraan.foto!.isEmpty)
                            ? const Icon(Icons.directions_car_filled_rounded, color: AppColors.textMuted, size: 28)
                            : Image.network(
                                _fotoUrl(kendaraan.foto!),
                                fit: BoxFit.cover,
                                // Header ini wajib supaya ngrok free tier
                                // langsung balikin gambar aslinya, bukan
                                // halaman peringatan browser interstitial.
                                headers: const {'ngrok-skip-browser-warning': 'true'},
                                loadingBuilder: (context, child, progress) => progress == null
                                    ? child
                                    : const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                                errorBuilder: (context, error, stack) =>
                                    const Icon(Icons.directions_car_filled_rounded, color: AppColors.textMuted, size: 28),
                              ),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kendaraan.nopol,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                      if ((kendaraan.merk ?? '').isNotEmpty)
                        Text(kendaraan.merk!, style: const TextStyle(fontSize: 13, color: AppColors.textBody)),
                      if ((kendaraan.warna ?? '').isNotEmpty)
                        Text(kendaraan.warna!, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Tersedia',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KonfirmasiDialog extends StatelessWidget {
  final KendaraanModel kendaraan;
  const _KonfirmasiDialog({required this.kendaraan});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.question_mark_rounded, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Konfirmasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Pilih kendaraan ${kendaraan.nopol} ini dan mulai perjalanan?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textBody, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Ya, Mulai'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}