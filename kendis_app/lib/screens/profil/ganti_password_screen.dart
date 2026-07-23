import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordLamaController =
      TextEditingController();

  final TextEditingController _passwordBaruController =
      TextEditingController();

  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  bool _obscurePasswordLama = true;
  bool _obscurePasswordBaru = true;
  bool _obscureKonfirmasiPassword = true;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  // =========================================================================
  // SIMPAN PASSWORD
  // =========================================================================

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.changePassword(
      passwordLama: _passwordLamaController.text,
      passwordBaru: _passwordBaruController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authProvider.errorMessage ??
                      'Gagal mengubah password',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('KEAMANAN AKUN'),

                      const SizedBox(height: 8),

                      Text(
                        'Pastikan Anda mengingat password baru '
                        'untuk login kembali ke akun Anda.',
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.5,
                          color: AppColors.textMuted,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =====================================================
                      // PASSWORD LAMA
                      // =====================================================

                      _buildPasswordField(
                        label: 'Password Lama',
                        hintText: 'Masukkan password lama',
                        controller: _passwordLamaController,
                        obscureText: _obscurePasswordLama,
                        onToggle: () {
                          setState(() {
                            _obscurePasswordLama =
                                !_obscurePasswordLama;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password lama wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // PASSWORD BARU
                      // =====================================================

                      _buildPasswordField(
                        label: 'Password Baru',
                        hintText: 'Masukkan password baru',
                        controller: _passwordBaruController,
                        obscureText: _obscurePasswordBaru,
                        onToggle: () {
                          setState(() {
                            _obscurePasswordBaru =
                                !_obscurePasswordBaru;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password baru wajib diisi';
                          }

                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }

                          if (value ==
                              _passwordLamaController.text) {
                            return 'Password baru tidak boleh sama';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // KONFIRMASI PASSWORD
                      // =====================================================

                      _buildPasswordField(
                        label: 'Konfirmasi Password Baru',
                        hintText: 'Ulangi password baru',
                        controller:
                            _konfirmasiPasswordController,
                        obscureText:
                            _obscureKonfirmasiPassword,
                        onToggle: () {
                          setState(() {
                            _obscureKonfirmasiPassword =
                                !_obscureKonfirmasiPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password wajib diisi';
                          }

                          if (value !=
                              _passwordBaruController.text) {
                            return 'Password tidak sama';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // =====================================================
                      // TOMBOL SIMPAN
                      // =====================================================

                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _savePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.primary
                                        .withOpacity(0.5),
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan Password',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
            'Ganti Password',
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
  // PASSWORD FIELD
  // =========================================================================

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
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

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
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
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 18,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.danger,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.danger,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}