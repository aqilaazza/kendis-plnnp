import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../models/kegiatan_model.dart';
import '../../services/kegiatan_service.dart';

class KegiatanScreen extends StatefulWidget {
  const KegiatanScreen({super.key});

  @override
  State<KegiatanScreen> createState() => _KegiatanScreenState();
}

class _KegiatanScreenState extends State<KegiatanScreen> {
  late Future<List<KegiatanModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = KegiatanService.getList();
  }

  void _reload() => setState(() => _future = KegiatanService.getList());

  void _showAddSheet() {
    final namaCtrl = TextEditingController();
    final tujuanCtrl = TextEditingController();
    DateTime tanggal = DateTime.now();
    TimeOfDay jam = TimeOfDay.now();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catat Kegiatan Harian', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  TextField(controller: namaCtrl, decoration: const InputDecoration(hintText: 'Nama kegiatan')),
                  const SizedBox(height: 10),
                  TextField(controller: tujuanCtrl, decoration: const InputDecoration(hintText: 'Tujuan')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx, initialDate: tanggal,
                              firstDate: DateTime(2020), lastDate: DateTime(2100),
                            );
                            if (picked != null) setModalState(() => tanggal = picked);
                          },
                          child: Text('${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: ctx, initialTime: jam);
                            if (picked != null) setModalState(() => jam = picked);
                          },
                          child: Text('${jam.hour.toString().padLeft(2, '0')}:${jam.minute.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting
                          ? null
                          : () async {
                              if (namaCtrl.text.trim().isEmpty || tujuanCtrl.text.trim().isEmpty) return;
                              setModalState(() => submitting = true);
                              try {
                                await KegiatanService.tambah(
                                  namaKegiatan: namaCtrl.text.trim(),
                                  tujuan: tujuanCtrl.text.trim(),
                                  tanggal: '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}',
                                  jam: '${jam.hour.toString().padLeft(2, '0')}:${jam.minute.toString().padLeft(2, '0')}:00',
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                _reload();
                              } on ApiException catch (e) {
                                setModalState(() => submitting = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.message)));
                                }
                              }
                            },
                      child: submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kegiatan Harian',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  IconButton(
                    onPressed: _showAddSheet,
                    icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<KegiatanModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return Center(child: Text('Belum ada kegiatan tercatat.', style: TextStyle(color: AppColors.textMuted)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final k = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.event_note, color: AppColors.accentGold, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(k.namaKegiatan, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(k.tujuan, style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                                ],
                              ),
                            ),
                            Text('${k.tanggal}\n${k.jam}', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
