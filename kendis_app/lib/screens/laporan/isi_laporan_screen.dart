import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../models/penugasan_model.dart';
import '../../services/laporan_service.dart';

final _idRupiah = NumberFormat.decimalPattern('id_ID');

/// Jenis field angka: menentukan keyboard & formatter apa yang dipakai.
enum _FieldKind { integer, decimal, currency }

/// Otomatis nambahin titik pemisah ribuan saat user ngetik angka uang,
/// contoh: ketik "100000" -> langsung tampil "100.000".
class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = _idRupiah.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Form pengisian laporan perjalanan.
///
/// Sengaja menerima [penugasan] (bukan cuma id) supaya kartu "Informasi
/// Perjalanan" di atas form bisa langsung ditampilkan tanpa fetch ulang —
/// dan supaya layar ini bisa dibuka LANGSUNG dari tombol "Isi Laporan
/// Perjalanan" di Detail Penugasan, tanpa lewat layar/dialog perantara.
class IsiLaporanScreen extends StatefulWidget {
  final PenugasanModel penugasan;
  const IsiLaporanScreen({super.key, required this.penugasan});

  @override
  State<IsiLaporanScreen> createState() => _IsiLaporanScreenState();
}

class _IsiLaporanScreenState extends State<IsiLaporanScreen> {
  final _odoStartCtrl = TextEditingController();
  final _odoStopCtrl = TextEditingController();
  final _literBbmCtrl = TextEditingController();
  final _hargaLiterCtrl = TextEditingController();
  final _rupiahTolCtrl = TextEditingController();
  final _rupiahParkirCtrl = TextEditingController();

  XFile? _fotoBbm, _fotoTol, _fotoParkir;
  bool _submitting = false;
  final _picker = ImagePicker();

  /// Parse teks yang sudah diformat pakai titik ribuan (mis. "100.000")
  /// balik jadi angka polos (100000).
  double _parseCurrency(String text) => double.tryParse(text.replaceAll('.', '')) ?? 0;

  double get _totalBbm {
    final liter = double.tryParse(_literBbmCtrl.text) ?? 0;
    final harga = _parseCurrency(_hargaLiterCtrl.text);
    return liter * harga;
  }

  @override
  void initState() {
    super.initState();
    // Total BBM dihitung otomatis dari liter x harga/liter, jadi field-nya
    // perlu ikut redraw setiap kali salah satu dari dua input itu berubah.
    _literBbmCtrl.addListener(() => setState(() {}));
    _hargaLiterCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [
      _odoStartCtrl,
      _odoStopCtrl,
      _literBbmCtrl,
      _hargaLiterCtrl,
      _rupiahTolCtrl,
      _rupiahParkirCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(Function(XFile) onPicked) async {
    // Di web, ImageSource.camera kadang gak didukung penuh oleh browser —
    // fallback ke gallery/file picker biar tetap jalan pas testing di Chrome.
    final source = kIsWeb ? ImageSource.gallery : ImageSource.camera;
    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) onPicked(picked);
  }

  /// Nampilin dialog "Apakah Anda yakin...?" sebelum beneran ngirim laporan
  /// ke server. Cuma lanjut ke _submit() kalau user tap "OK".
  Future<void> _confirmAndSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.1)),
                    child: Icon(Icons.help_outline, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Konfirmasi',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Apakah Anda yakin ingin melanjutkan proses pengiriman laporan ini? '
                'Pastikan semua data telah terverifikasi dengan benar.',
                style: TextStyle(fontSize: 13.5, color: AppColors.textBody, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('OK'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) _submit();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await LaporanService.submit(
        idPenugasan: widget.penugasan.id,
        literBbm: double.tryParse(_literBbmCtrl.text) ?? 0,
        rupiahBbm: _totalBbm,
        rupiahParkir: _parseCurrency(_rupiahParkirCtrl.text),
        rupiahTol: _parseCurrency(_rupiahTolCtrl.text),
        odoStart: int.tryParse(_odoStartCtrl.text) ?? 0,
        odoStop: int.tryParse(_odoStopCtrl.text) ?? 0,
        fotoBbm: _fotoBbm,
        fotoParkir: _fotoParkir,
        fotoTol: _fotoTol,
        fotoOdoStart: null,
        fotoOdoStop: null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.penugasan;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const Text('Pelaporan Perjalanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Lengkapi data operasional perjalanan Anda.',
                style: TextStyle(color: AppColors.textBody, fontSize: 13)),
            const SizedBox(height: 16),

            // === Kartu ringkasan penugasan (read-only) ===
            _InfoCard(
              title: 'Informasi Perjalanan',
              icon: Icons.info_outline,
              rows: [
                _InfoRow(label: 'Kode Request', value: p.kodeRequest, valueColor: AppColors.primary),
                _InfoRow(label: 'Kota Tujuan', value: p.tempatTujuan),
                if (p.lokasiTujuan != null && p.lokasiTujuan!.isNotEmpty)
                  _InfoRow(label: 'Lokasi Tujuan Detail', value: p.lokasiTujuan!),
                _InfoRow(label: 'Kendaraan Dinas', value: p.nopol ?? '-'),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text('Detail Operasional',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Wajib Diisi',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.warning)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // === Odometer ===
            _SectionCard(
              icon: Icons.speed,
              title: 'Odometer',
              children: [
                Row(
                  children: [
                    Expanded(child: _labeledField('Odometer Mulai (KM)', _odoStartCtrl, kind: _FieldKind.integer)),
                    const SizedBox(width: 10),
                    Expanded(child: _labeledField('Odometer Selesai (KM)', _odoStopCtrl, kind: _FieldKind.integer)),
                  ],
                ),
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
                    Expanded(child: _labeledField('Jumlah Liter', _literBbmCtrl, kind: _FieldKind.decimal)),
                    const SizedBox(width: 10),
                    Expanded(child: _labeledField('Harga / Liter (Rp)', _hargaLiterCtrl, kind: _FieldKind.currency)),
                  ],
                ),
                const SizedBox(height: 10),
                _ReadonlyTotalField(label: 'Total Rupiah BBM', value: 'Rp ${_idRupiah.format(_totalBbm)}'),
                const SizedBox(height: 14),
                _bukitFotoButton('Foto Bukti Nota BBM (opsional)', _fotoBbm, (f) => setState(() => _fotoBbm = f)),
              ],
            ),
            const SizedBox(height: 14),

            // === Tol & Parkir ===
            _SectionCard(
              icon: Icons.local_parking_outlined,
              title: 'Tol & Parkir',
              children: [
                _labeledField('Biaya Tol (Rp)', _rupiahTolCtrl, kind: _FieldKind.currency),
                const SizedBox(height: 10),
                _bukitFotoButton('Bukti Tol', _fotoTol, (f) => setState(() => _fotoTol = f)),
                const SizedBox(height: 16),
                _labeledField('Biaya Parkir (Rp)', _rupiahParkirCtrl, kind: _FieldKind.currency),
                const SizedBox(height: 10),
                _bukitFotoButton('Bukti Parkir', _fotoParkir, (f) => setState(() => _fotoParkir = f)),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _confirmAndSubmit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(_submitting ? 'Mengirim...' : 'Kirim Laporan & Selesai Tugas'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan foto struk terlihat jelas dan angka odometer sesuai dengan dashboard kendaraan.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Label field ditaruh sebagai teks biasa DI LUAR box (bukan hintText di
  /// dalam box), biar selalu kebaca meski field-nya udah diisi.
  Widget _labeledField(String label, TextEditingController controller, {_FieldKind kind = _FieldKind.integer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textBody, fontWeight: FontWeight.w500)),
        ),
        _numberField(controller, kind: kind),
      ],
    );
  }

  Widget _numberField(TextEditingController controller, {_FieldKind kind = _FieldKind.integer}) {
    TextInputType keyboardType;
    List<TextInputFormatter> formatters;
    String? prefixText;

    switch (kind) {
      case _FieldKind.integer:
        keyboardType = TextInputType.number;
        formatters = [FilteringTextInputFormatter.digitsOnly];
        break;
      case _FieldKind.decimal:
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
        formatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
        break;
      case _FieldKind.currency:
        keyboardType = TextInputType.number;
        formatters = [FilteringTextInputFormatter.digitsOnly, _ThousandsInputFormatter()];
        prefixText = 'Rp ';
        break;
    }

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      decoration: InputDecoration(
        hintText: '0',
        prefixText: prefixText,
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _bukitFotoButton(String label, XFile? file, ValueChanged<XFile?> onPicked) {
    final taken = file != null;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: taken ? AppColors.success.withOpacity(0.08) : AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: taken ? AppColors.success.withOpacity(0.4) : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              // Tap area teks: pilih foto baru (atau ganti yang sudah ada).
              onTap: () => _pickImage(onPicked),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(taken ? Icons.check_circle : Icons.camera_alt_outlined,
                      size: 16, color: taken ? AppColors.success : AppColors.textMuted),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      // Kalau sudah ada foto, tampilkan nama filenya biar user
                      // tahu file mana yang bakal ke-upload — bukan cuma "terpilih".
                      taken ? file.name : label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: taken ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (taken) ...[
            const SizedBox(width: 6),
            InkWell(
              // Tombol batal: hapus foto yang sudah dipilih tanpa harus
              // buka kamera/galeri lagi kalau jadinya gak mau diupload.
              onTap: () => onPicked(null),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 15, color: AppColors.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu ringkasan info penugasan (read-only) di bagian atas form.
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;
  const _InfoCard({required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu section form (Odometer / BBM / Tol & Parkir) dengan ikon + judul.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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

/// Field total yang dihitung otomatis (read-only), dipakai untuk Total Rupiah BBM.
class _ReadonlyTotalField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadonlyTotalField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }
}