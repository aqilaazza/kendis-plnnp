import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/penugasan_model.dart';
import '../services/penugasan_service.dart';
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
                const Text('Penugasan Saya',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterChip(label: 'Semua', value: 'semua', selected: _filter, onTap: _setFilter),
                const SizedBox(width: 8),
                _FilterChip(label: 'Aktif', value: 'aktif', selected: _filter, onTap: _setFilter),
                const SizedBox(width: 8),
                _FilterChip(label: 'Selesai', value: 'selesai', selected: _filter, onTap: _setFilter),
              ],
            ),
          ),
          const SizedBox(height: 12),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PenugasanDetailScreen(id: penugasan.id)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(penugasan.kodeRequest,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(penugasan.statusLabel,
                          style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(penugasan.tempatTujuan, style: TextStyle(color: AppColors.textBody, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${penugasan.tanggalBerangkat}  ${penugasan.jamBerangkat}',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
