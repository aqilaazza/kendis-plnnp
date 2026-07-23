import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _noSimController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Ambil data user yang sedang login
    final user = context.read<AuthProvider>().currentUser;

    _noHpController.text = user?.noHp ?? '';
    _noSimController.text = user?.noSim ?? '';
  }

  @override
  void dispose() {
    _noHpController.dispose();
    _noSimController.dispose();
    super.dispose();
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // ===============================================================
            // HEADER
            // ===============================================================

            _buildHeader(context),

            // ===============================================================
            // CONTENT
            // ===============================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  24,
                  18,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // INFORMASI AKUN
                    // =========================================================

                    _sectionLabel('INFORMASI AKUN'),

                    const SizedBox(height: 8),

                    _buildReadOnlyField(
                      label: 'Nama',
                      value: user?.nama ?? '-',
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 12),

                    _buildReadOnlyField(
                      label: 'NID',
                      value: user?.nid ?? '-',
                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // INFORMASI KONTAK
                    // =========================================================

                    _sectionLabel('INFORMASI KONTAK'),

                    const SizedBox(height: 8),

                    _buildTextField(
                      label: 'Nomor HP',
                      hintText: 'Masukkan nomor HP',
                      controller: _noHpController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      label: 'Nomor SIM',
                      hintText: 'Masukkan nomor SIM',
                      controller: _noSimController,
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),

                    const SizedBox(height: 28),

                    // =========================================================
                    // TOMBOL SIMPAN
                    // =========================================================

                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          _saveProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HEADER
  // =========================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Edit Profil',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION LABEL
  // =========================================================================

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.6,
      ),
    );
  }

  // =========================================================================
  // READ ONLY FIELD
  // =========================================================================

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 18,
              color: AppColors.textMuted,
            ),
            suffixIcon: const Icon(
              Icons.lock_outline,
              size: 15,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // EDITABLE FIELD
  // =========================================================================

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SAVE PROFILE
  // =========================================================================

  Future<void> _saveProfile() async {
    final noHp = _noHpController.text.trim();
    final noSim = _noSimController.text.trim();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updateProfile(
      noHp: noHp,
      noSim: noSim,
    );

    if (!mounted) return;

    if (success) {
      // Kembali ke halaman Profil
      // true = menandakan update berhasil
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Gagal memperbarui profil',
          ),
        ),
      );
    }
  }

}