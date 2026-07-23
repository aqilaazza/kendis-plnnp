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
            // =============================================================
            // HEADER
            // =============================================================
            _buildHeader(context),

            // =============================================================
            // CONTENT
            // =============================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 48,
                ),
                child: Column(
                  children: [
                    // =======================================================
                    // FOTO PROFIL
                    // =======================================================
                    _buildProfilePhoto(),

                    const SizedBox(height: 16),

                    // =======================================================
                    // NAMA
                    // =======================================================
                    const Text(
                      'Kendis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // =======================================================
                    // ROLE
                    // =======================================================
                    Text(
                      'Driver',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =======================================================
                    // UNGGAH FOTO
                    // =======================================================
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO:
                          // Pilih foto dari galeri
                        },
                        icon: const Icon(
                          Icons.file_upload_outlined,
                          size: 15,
                        ),
                        label: const Text(
                          'Unggah Foto',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    // =======================================================
                    // AMBIL FOTO
                    // =======================================================
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO:
                          // Buka kamera
                        },
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          size: 15,
                        ),
                        label: const Text(
                          'Ambil Foto',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =======================================================
                    // HAPUS FOTO
                    // =======================================================
                    TextButton.icon(
                      onPressed: () {
                        // TODO:
                        // Konfirmasi hapus foto
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: AppColors.danger,
                      ),
                      label: const Text(
                        'Hapus Foto',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.danger,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // =======================================================
                    // INFO KETENTUAN FOTO
                    // =======================================================
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
            'Foto Profil',
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
  // PROFILE PHOTO
  // =========================================================================

  Widget _buildProfilePhoto() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const ClipOval(
        child: Center(
          child: Icon(
            Icons.person,
            size: 40,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // PHOTO REQUIREMENT
  // =========================================================================

  Widget _buildPhotoRequirement() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.primary,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ketentuan Foto',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '• Format file JPG, JPEG atau PNG\n'
                  '• Ukuran maksimal file 2MB\n'
                  '• Pastikan wajah terlihat jelas',
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}