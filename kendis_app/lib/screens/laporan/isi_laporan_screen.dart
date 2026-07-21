import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../services/laporan_service.dart';

class IsiLaporanScreen extends StatefulWidget {
  final int idPenugasan;
  const IsiLaporanScreen({super.key, required this.idPenugasan});

  @override
  State<IsiLaporanScreen> createState() => _IsiLaporanScreenState();
}

class _IsiLaporanScreenState extends State<IsiLaporanScreen> {
  final _literBbmCtrl = TextEditingController();
  final _rupiahBbmCtrl = TextEditingController();
  final _rupiahParkirCtrl = TextEditingController();
  final _rupiahTolCtrl = TextEditingController();
  final _odoStartCtrl = TextEditingController();
  final _odoStopCtrl = TextEditingController();

  File? _fotoBbm, _fotoParkir, _fotoTol, _fotoOdoStart, _fotoOdoStop;
  bool _submitting = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    for (final c in [_literBbmCtrl, _rupiahBbmCtrl, _rupiahParkirCtrl, _rupiahTolCtrl, _odoStartCtrl, _odoStopCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(Function(File) onPicked) async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (picked != null) onPicked(File(picked.path));
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await LaporanService.submit(
        idPenugasan: widget.idPenugasan,
        literBbm: double.tryParse(_literBbmCtrl.text) ?? 0,
        rupiahBbm: double.tryParse(_rupiahBbmCtrl.text) ?? 0,
        rupiahParkir: double.tryParse(_rupiahParkirCtrl.text) ?? 0,
        rupiahTol: double.tryParse(_rupiahTolCtrl.text) ?? 0,
        odoStart: int.tryParse(_odoStartCtrl.text) ?? 0,
        odoStop: int.tryParse(_odoStopCtrl.text) ?? 0,
        fotoBbm: _fotoBbm,
        fotoParkir: _fotoParkir,
        fotoTol: _fotoTol,
        fotoOdoStart: _fotoOdoStart,
        fotoOdoStop: _fotoOdoStop,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Isi Laporan Perjalanan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle('Odometer'),
            _numberField(_odoStartCtrl, 'Odometer Awal (km)'),
            _photoPicker('Foto Odometer Awal', _fotoOdoStart, (f) => setState(() => _fotoOdoStart = f)),
            const SizedBox(height: 8),
            _numberField(_odoStopCtrl, 'Odometer Akhir (km)'),
            _photoPicker('Foto Odometer Akhir', _fotoOdoStop, (f) => setState(() => _fotoOdoStop = f)),

            const SizedBox(height: 20),
            _sectionTitle('Bahan Bakar (BBM)'),
            _numberField(_literBbmCtrl, 'Jumlah BBM (liter)'),
            _numberField(_rupiahBbmCtrl, 'Biaya BBM (Rp)'),
            _photoPicker('Foto Struk BBM', _fotoBbm, (f) => setState(() => _fotoBbm = f)),

            const SizedBox(height: 20),
            _sectionTitle('Parkir'),
            _numberField(_rupiahParkirCtrl, 'Biaya Parkir (Rp)'),
            _photoPicker('Foto Struk Parkir', _fotoParkir, (f) => setState(() => _fotoParkir = f)),

            const SizedBox(height: 20),
            _sectionTitle('Tol'),
            _numberField(_rupiahTolCtrl, 'Biaya Tol (Rp)'),
            _photoPicker('Foto Struk Tol', _fotoTol, (f) => setState(() => _fotoTol = f)),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Kirim Laporan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
      );

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(hintText: label),
      ),
    );
  }

  Widget _photoPicker(String label, File? file, Function(File) onPicked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _pickImage(onPicked),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: file != null ? AppColors.primary : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(file != null ? Icons.check_circle : Icons.camera_alt_outlined,
                  color: file != null ? AppColors.success : AppColors.textMuted, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file != null ? '$label — foto terpilih' : label,
                  style: TextStyle(color: file != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
