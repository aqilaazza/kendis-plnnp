import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(
                  18,
                  24,
                  18,
                  32,
                ),
                child: Column(
                  children: [
                    // =======================================================
                    // APP IDENTITY
                    // =======================================================

                    _buildAppIdentity(),

                    const SizedBox(height: 24),

                    // =======================================================
                    // TENTANG APLIKASI
                    // =======================================================

                    _sectionLabel('TENTANG APLIKASI'),

                    const SizedBox(height: 8),

                    _buildDescriptionCard(),

                    const SizedBox(height: 20),

                    // =======================================================
                    // INFORMASI APLIKASI
                    // =======================================================

                    _sectionLabel('INFORMASI APLIKASI'),

                    const SizedBox(height: 8),

                    _buildInfoCard(),

                    const SizedBox(height: 24),

                    // =======================================================
                    // COPYRIGHT
                    // =======================================================

                    _buildCopyright(),
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
            'Tentang Aplikasi',
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
  // APP IDENTITY
  // =========================================================================

  Widget _buildAppIdentity() {
    return Column(
      children: [
        // Logo aplikasi
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_car_filled_outlined,
            size: 38,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 14),

        // Nama aplikasi
        const Text(
          'Kendis Driver',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 4),

        // Versi
        Text(
          'Versi 1.0.0',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION LABEL
  // =========================================================================

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // =========================================================================
  // DESCRIPTION CARD
  // =========================================================================

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'Kendis Driver merupakan aplikasi yang digunakan oleh driver '
        'untuk membantu mengelola penugasan kendaraan dinas, melihat '
        'informasi perjalanan, serta memantau aktivitas tugas secara '
        'lebih mudah dan terorganisir.',
        style: TextStyle(
          fontSize: 11,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // =========================================================================
  // INFORMATION CARD
  // =========================================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.apps_outlined,
            label: 'Nama Aplikasi',
            value: 'Kendis Driver',
          ),

          _buildDivider(),

          _buildInfoTile(
            icon: Icons.info_outline,
            label: 'Versi',
            value: '1.0.0',
          ),

          _buildDivider(),

          _buildInfoTile(
            icon: Icons.business_outlined,
            label: 'Pengembang',
            value: 'PLN Nusantara Power',
          ),

          _buildDivider(),

          _buildInfoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Tahun',
            value: '2026',
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // INFO TILE
  // =========================================================================

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ),

          // Value
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // DIVIDER
  // =========================================================================

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 58,
      endIndent: 12,
    );
  }

  // =========================================================================
  // COPYRIGHT
  // =========================================================================

  Widget _buildCopyright() {
    return Column(
      children: [
        Text(
          'Kendis Driver',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          '© 2026 PLN Nusantara Power. Hak cipta dilindungi.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 8,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}