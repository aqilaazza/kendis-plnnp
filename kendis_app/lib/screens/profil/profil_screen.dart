import 'package:flutter/material.dart';
import 'package:kendis_driver_app/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'foto_profil_screen.dart';
import 'edit_profil_screen.dart';
import 'ganti_password_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,

      // Bottom navbar tidak kita ubah.
      body: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // HEADER
            // =========================================================
            _buildHeader(context),

            // =========================================================
            // CONTENT
            // =========================================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  24,
                ),
                children: [
                  // =====================================================
                  // PROFILE CARD
                  // =====================================================
                  _buildProfileCard(context, user),

                  const SizedBox(height: 20),

                  // =====================================================
                  // AKUN
                  // =====================================================
                  _sectionLabel('AKUN'),

                  _menuCard(
                    children: [
                      _MenuTile(
                        icon: Icons.person_outline,
                        label: 'Edit Profil',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilScreen(),
                            ),
                          );

                          if (result == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Profil berhasil diperbarui',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                elevation: 4,
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      _MenuTile(
                        icon: Icons.lock_reset_outlined,
                        label: 'Ganti Password',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GantiPasswordScreen(),
                            ),
                          );

                          if (result == true && context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Password berhasil diperbarui',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              elevation: 4,
                              margin: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      _MenuTile(
                        icon: Icons.notifications_none_outlined,
                        label: 'Pengaturan Notifikasi',
                        onTap: () {
                          // Nanti diarahkan ke NotificationSettingsScreen
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // LAINNYA
                  // =====================================================
                  _sectionLabel('LAINNYA'),

                  _menuCard(
                    children: [
                      _MenuTile(
                        icon: Icons.help_outline,
                        label: 'Pusat Bantuan',
                        onTap: () {
                          // Nanti diarahkan ke HelpCenterScreen
                        },
                      ),
                      _MenuTile(
                        icon: Icons.info_outline,
                        label: 'Tentang Aplikasi',
                        onTap: () {
                          // Nanti diarahkan ke AboutAppScreen
                        },
                      ),
                      _MenuTile(
                        icon: Icons.logout_outlined,
                        label: 'Keluar',
                        isDanger: true,
                        showArrow: false,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // =====================================================
                  // APP VERSION
                  // =====================================================
                  _buildAppVersion(),
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              // TODO: Buka halaman notifikasi
            },
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 21,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // PROFILE CARD
  // =========================================================================

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    final String nama = user?.nama ?? '-';
    final String nid = user?.nid ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
                child: ClipOval(
                  child: Center(
                    child: Text(
                      nama.isNotEmpty && nama != '-'
                          ? nama[0].toUpperCase()
                          : 'D',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              // ICON PENSIL
              Positioned(
                right: -1,
                bottom: -1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FotoProfilScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nid,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 10,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'Driver',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 8,
      ),
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
  // MENU CARD
  // =========================================================================

  Widget _menuCard({
    required List<Widget> children,
  }) {
    return Container(
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
        children: children,
      ),
    );
  }

  // =========================================================================
  // APP VERSION
  // =========================================================================

  Widget _buildAppVersion() {
    return Column(
      children: [
        Text(
          'Aeon Pro v2.4.1 (Stable)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '© 2024 Aeon Professional. Hak cipta dilindungi.',
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

// =============================================================================
// MENU TILE
// =============================================================================

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  final bool showArrow;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDanger ? AppColors.danger : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade100,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // =============================================================
              // ICON
              // =============================================================
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDanger
                      ? AppColors.danger.withOpacity(0.06)
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              // =============================================================
              // LABEL
              // =============================================================
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),

              // =============================================================
              // ARROW
              // =============================================================
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
