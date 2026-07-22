import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/penugasan_model.dart';
import '../../services/penugasan_service.dart';
import 'penugasan_detail_screen.dart';

class PenugasanListScreen extends StatefulWidget {
  const PenugasanListScreen({super.key});

  @override
  State<PenugasanListScreen> createState() => _PenugasanListScreenState();
}

class _PenugasanListScreenState extends State<PenugasanListScreen> {
  String _filter = 'semua';
  late Future<List<PenugasanModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = PenugasanService.getList(status: _filter);
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
      _future = PenugasanService.getList(status: filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Riwayat Penugasan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Daftar perjalanan yang telah dikirim.",
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20),
            child: Container(
              height:120,
              width:double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Kualitas Armada Nomor Satu",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:18,
                      ),
                    ),

                    SizedBox(height:8),

                    Text(
                      "Menjadi armada operasional terpercaya.",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    value: 'semua',
                    selected: _filter,
                    onTap: _setFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Menunggu',
                    value: 'menunggu',
                    selected: _filter,
                    onTap: _setFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Diproses',
                    value: 'diproses',
                    selected: _filter,
                    onTap: _setFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Selesai',
                    value: 'selesai',
                    selected: _filter,
                    onTap: _setFilter,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari laporan...",
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
            ),
          ),

          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<PenugasanModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat: ${snapshot.error}'));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(child: Text('Belum ada penugasan.', style: TextStyle(color: AppColors.textMuted)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final p = list[index];
                    return _PenugasanTile(penugasan: p);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onTap;
  const _FilterChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textBody,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PenugasanTile extends StatelessWidget {
  final PenugasanModel penugasan;
  const _PenugasanTile({required this.penugasan});

  Color get _statusColor {
    switch (penugasan.statusRequest) {
      case 'on_trip':
        return AppColors.warning;
      case 'completed':
      case 'rated':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

    Widget _buildItem(
      IconData icon,
      String title,
      String value,
    ) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              ],
            ),
          ),

        ],
      );
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PenugasanDetailScreen(
                  id: penugasan.id,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Expanded(
                      child: Text(
                        penugasan.kodeRequest,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        penugasan.statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 18),

                _buildItem(
                  Icons.person_outline,
                  "Pemohon",
                  penugasan.namaPemohon ?? "-",
                ),

                const SizedBox(height: 10),

                _buildItem(
                  Icons.location_on_outlined,
                  "Tujuan",
                  penugasan.tempatTujuan,
                ),

                const SizedBox(height: 10),

                _buildItem(
                  Icons.work_outline,
                  "Kegiatan",
                  penugasan.kegiatan,
                ),

                const SizedBox(height: 10),

                _buildItem(
                  Icons.calendar_today_outlined,
                  "Berangkat",
                  "${penugasan.tanggalBerangkat} • ${penugasan.jamBerangkat}",
                ),

                if (penugasan.jamKembali != null) ...[
                  const SizedBox(height: 10),
                  _buildItem(
                    Icons.access_time,
                    "Kembali",
                    penugasan.jamKembali!,
                  ),
                ],

                const Divider(height: 30),

                Row(
                  children: [

                    const Icon(
                      Icons.directions_car,
                      color: AppColors.primary,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        "${penugasan.merkKendaraan ?? '-'} (${penugasan.nopol ?? '-'})",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PenugasanDetailScreen(
                            id: penugasan.id,
                          ),
                        ),
                      );
                    },
                    child: const Text("Lihat Detail"),
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
