import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../models/penugasan_model.dart';

final _rupiah = NumberFormat.decimalPattern('id_ID');

/// Menampilkan detail laporan yang SUDAH dikirim driver — dibuka dari
/// kartu Riwayat di LaporanScreen. Datanya sudah nempel langsung di
/// PenugasanModel (ikut dari LEFT JOIN laporan_driver di endpoint list),
/// jadi tidak perlu fetch API tambahan.
class DetailLaporanScreen extends StatelessWidget {
  final PenugasanModel penugasan;
  const DetailLaporanScreen({super.key, required this.penugasan});

  @override
  Widget build(BuildContext context) {
    final p = penugasan;
    final totalBiaya = (p.rupiahBbm ?? 0) + (p.rupiahTol ?? 0) + (p.rupiahParkir ?? 0);
    final adaFoto = [p.fotoBbmUrl, p.fotoTolUrl, p.fotoParkirUrl].any((e) => e != null && e.isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: const Text('Detail Laporan'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _HeaderTerkirim(penugasan: p),
            const SizedBox(height: 16),

            // === Informasi Perjalanan ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(p.kodeRequest,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                      ),
                      _StatusChip(penugasan: p),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _LabeledStat(icon: Icons.location_on_outlined, label: 'Kota Tujuan', value: p.tempatTujuan)),
                      if (p.lokasiTujuan != null && p.lokasiTujuan!.isNotEmpty)
                        Expanded(child: _LabeledStat(icon: Icons.place_outlined, label: 'Lokasi Detail', value: p.lokasiTujuan!)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LabeledStat(icon: Icons.directions_car_outlined, label: 'Kendaraan Dinas', value: p.nopol ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // === Odometer ===
            _SectionCard(
              icon: Icons.speed,
              title: 'Odometer',
              children: [
                Row(
                  children: [
                    Expanded(child: _StatBox(label: 'MULAI', value: '${_rupiah.format(p.odoStart ?? 0)} km')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatBox(label: 'SELESAI', value: '${_rupiah.format(p.odoStop ?? 0)} km')),
                  ],
                ),
                const SizedBox(height: 10),
                _KV(label: 'Jarak Tempuh', value: '${_rupiah.format(p.jarakKm ?? 0)} km', valueColor: AppColors.primary),
              ],
            ),
            const SizedBox(height: 14),

            // === Bahan Bakar (BBM) ===
            _SectionCard(
              icon: Icons.local_gas_station_outlined,
              title: 'Bahan Bakar (BBM)',
              children: [
                Row(
                  children: [
                    Expanded(child: _StackedKV(label: 'Jumlah Liter', value: '${p.literBbm ?? 0} Liter')),
                    const SizedBox(width: 16),
                    Expanded(child: _StackedKV(label: 'Harga per Liter', value: 'Rp ${_rupiah.format(p.hargaPerLiter.round())}')),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _KV(label: 'Total Rupiah', value: 'Rp ${_rupiah.format(p.rupiahBbm ?? 0)}', valueColor: AppColors.primary),
              ],
            ),
            const SizedBox(height: 14),

            // === Tol & Parkir ===
            _SectionCard(
              icon: Icons.local_parking_outlined,
              title: 'Tol & Parkir',
              children: [
                Row(
                  children: [
                    Expanded(child: _StatBox(label: 'BIAYA TOL', value: 'Rp ${_rupiah.format(p.rupiahTol ?? 0)}')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatBox(label: 'BIAYA PARKIR', value: 'Rp ${_rupiah.format(p.rupiahParkir ?? 0)}')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // === Total Keseluruhan ===
            _SectionCard(
              icon: Icons.receipt_long_outlined,
              title: 'Total Keseluruhan',
              children: [
                _KV(label: 'Total Biaya Perjalanan', value: 'Rp ${_rupiah.format(totalBiaya)}', valueColor: AppColors.primary),
              ],
            ),
            const SizedBox(height: 14),

            // === Dokumentasi & Lampiran ===
            if (adaFoto)
              _SectionCard(
                icon: Icons.image_outlined,
                title: 'Dokumentasi & Lampiran',
                children: [
                  Row(
                    children: [
                      if (p.fotoBbmUrl != null && p.fotoBbmUrl!.isNotEmpty)
                        Expanded(child: _FotoThumb(label: 'Nota BBM', url: p.fotoBbmUrl!)),
                      if (p.fotoBbmUrl != null && p.fotoBbmUrl!.isNotEmpty) const SizedBox(width: 8),
                      if (p.fotoTolUrl != null && p.fotoTolUrl!.isNotEmpty)
                        Expanded(child: _FotoThumb(label: 'Bukti Tol', url: p.fotoTolUrl!)),
                      if (p.fotoTolUrl != null && p.fotoTolUrl!.isNotEmpty) const SizedBox(width: 8),
                      if (p.fotoParkirUrl != null && p.fotoParkirUrl!.isNotEmpty)
                        Expanded(child: _FotoThumb(label: 'Bukti Parkir', url: p.fotoParkirUrl!)),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Tutup & Kembali ke Riwayat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header hijau "Laporan Berhasil Dikirim" + tanggal + badge status.
class _HeaderTerkirim extends StatelessWidget {
  final PenugasanModel penugasan;
  const _HeaderTerkirim({required this.penugasan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.15)),
            child: Icon(Icons.check_circle, color: AppColors.success, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Laporan Berhasil Dikirim',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  'TERARSIP PADA ${(penugasan.tanggalLapor ?? penugasan.tanggalBerangkat).toUpperCase()}',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge kecil "Selesai" / "Disetujui" / "Terkirim" di kartu Informasi Perjalanan.
class _StatusChip extends StatelessWidget {
  final PenugasanModel penugasan;
  const _StatusChip({required this.penugasan});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;

    if (penugasan.statusRequest == 'rated') {
      color = AppColors.success;
      label = 'Disetujui';
    } else if (penugasan.statusRequest == 'completed') {
      color = AppColors.success;
      label = 'Selesai';
    } else {
      color = const Color(0xFF2563EB);
      label = 'Terkirim';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

/// Baris ikon + label kecil + value, dipakai di kartu Informasi Perjalanan.
class _LabeledStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _LabeledStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// Kotak stat rata-tengah (label kecil di atas, angka besar di bawah) —
/// dipakai untuk Odometer Mulai/Selesai dan Tol/Parkir supaya tidak
/// berdempetan seperti versi Row+spaceBetween sebelumnya.
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _KV({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}

/// Label kecil di atas, value di bawah — dipakai kalau dua kolom sejajar
/// dalam Row supaya label & value tidak bentrok saat lebar kolom sempit
/// (beda dengan _KV yang naruh label & value sebaris).
class _StackedKV extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StackedKV({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _FotoThumb extends StatelessWidget {
  final String label;
  final String url;
  const _FotoThumb({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(url))),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.inputFill,
                  child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label.toUpperCase(),
              style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}