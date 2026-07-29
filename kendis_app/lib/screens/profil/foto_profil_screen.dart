import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class FotoProfilScreen extends StatelessWidget {
  const FotoProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // HEADER
            // =================================================================
            _buildHeader(context),

            // =================================================================
            // CONTENT
            // =================================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: Column(
                  children: [
                    // FOTO PROFIL
                    _buildProfilePhoto(),
                    const SizedBox(height: 16),

                    // NAMA
                    const Text(
                      'Kendis',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ROLE
                    const Text(
                      'Driver',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),

                    // UNGGAH FOTO
                    _actionButton(
                      label: 'Unggah Foto',
                      icon: Icons.file_upload_outlined,
                      filled: true,
                      onTap: () {
                        // TODO: Pilih foto dari galeri
                      },
                    ),
                    const SizedBox(height: 10),

                    // AMBIL FOTO
                    _actionButton(
                      label: 'Ambil Foto',
                      icon: Icons.camera_alt_outlined,
                      filled: false,
                      onTap: () {
                        // TODO: Buka kamera
                      },
                    ),
                    const SizedBox(height: 16),

                    // HAPUS FOTO
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Konfirmasi hapus foto
                      },
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                      label: const Text(
                        'Hapus Foto',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // INFO KETENTUAN FOTO
                    _buildPhotoRequirement(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // HEADER
  // ===================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back, size: 22, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Foto Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // PROFILE PHOTO
  // ===================================================================

  Widget _buildProfilePhoto() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const ClipOval(
        child: Center(
          child: Icon(Icons.person, size: 56, color: AppColors.primary),
        ),
      ),
    );
  }

  // ===================================================================
  // ACTION BUTTON (Unggah Foto / Ambil Foto)
  // ===================================================================

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
    );
  }

  // ===================================================================
  // PHOTO REQUIREMENT
  // ===================================================================

  Widget _buildPhotoRequirement() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ketentuan Foto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '• Format file JPG, JPEG atau PNG\n'
                  '• Ukuran maksimal file 2MB\n'
                  '• Pastikan wajah terlihat jelas',
                  style: TextStyle(fontSize: 11, height: 1.6, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}