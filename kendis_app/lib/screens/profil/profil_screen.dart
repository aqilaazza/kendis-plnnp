import 'package:flutter/material.dart';
import 'package:kendis_driver_app/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'edit_profil_screen.dart';
import 'ganti_password_screen.dart';
import 'pengaturan_notifikasi_screen.dart';
import 'pusat_bantuan_screen.dart';
import 'tentang_aplikasi_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  // ---------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 260,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout_outlined, size: 18, color: AppColors.danger),
                  SizedBox(width: 8),
                  Text('Keluar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.danger)),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Apakah Anda yakin ingin keluar dari\naplikasi?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('OK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // ---------------------------------------------------------------------
  // SNACKBAR SUKSES (dipakai bareng oleh Edit Profil & Ganti Password)
  // ---------------------------------------------------------------------

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ---------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _buildProfileCard(context, user),
                  const SizedBox(height: 20),

                  _sectionLabel('AKUN'),
                  _menuCard(children: [
                    _MenuTile(
                      icon: Icons.person_outline,
                      label: 'Edit Profil',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfilScreen()),
                        );
                        if (result == true && context.mounted) {
                          _showSuccessSnackBar(context, 'Profil berhasil diperbarui');
                        }
                      },
                    ),
                    _MenuTile(
                      icon: Icons.lock_reset_outlined,
                      label: 'Ganti Password',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GantiPasswordScreen()),
                        );
                        if (result == true && context.mounted) {
                          _showSuccessSnackBar(context, 'Password berhasil diperbarui');
                        }
                      },
                    ),
                    _MenuTile(
                      icon: Icons.notifications_none_outlined,
                      label: 'Pengaturan Notifikasi',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PengaturanNotifikasiScreen()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _sectionLabel('LAINNYA'),
                  _menuCard(children: [
                    _MenuTile(
                      icon: Icons.help_outline,
                      label: 'Pusat Bantuan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PusatBantuanScreen()),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.info_outline,
                      label: 'Tentang Aplikasi',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TentangAplikasiScreen()),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.logout_outlined,
                      label: 'Keluar',
                      isDanger: true,
                      showArrow: false,
                      onTap: () => _confirmLogout(context),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  _buildAppVersion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------

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
          const Text('Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Spacer(),
          InkWell(
            onTap: () {
              // TODO: Buka halaman notifikasi
            },
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.notifications_none_outlined, size: 22, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // PROFILE CARD
  // ---------------------------------------------------------------------

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    final String nama = user?.nama ?? '-';
    final String nid = user?.nid ?? '-';
    final String noSim = user?.noSim ?? '-';
    final String noHp = user?.noHp ?? '-';
    final String role = user?.role ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.08)),
            child: ClipOval(
              child: Center(
                child: Text(
                  nama.isNotEmpty && nama != '-' ? nama[0].toUpperCase() : 'D',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 8),
                _profileInfoRow(icon: Icons.badge_outlined, label: 'NID', value: nid),
                const SizedBox(height: 5),
                _profileInfoRow(icon: Icons.phone_outlined, label: 'No. HP', value: noHp),
                const SizedBox(height: 5),
                _profileInfoRow(icon: Icons.credit_card_outlined, label: 'No. SIM', value: noSim),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : '-',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
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

  Widget _profileInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // SECTION LABEL / MENU CARD
  // ---------------------------------------------------------------------

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.6),
      ),
    );
  }

  Widget _menuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ---------------------------------------------------------------------
  // APP VERSION
  // ---------------------------------------------------------------------

  Widget _buildAppVersion() {
    return const Column(
      children: [
        Text('Aeon Pro v2.4.1 (Stable)',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        SizedBox(height: 3),
        Text('© 2024 Aeon Professional. Hak cipta dilindungi.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
    final color = isDanger ? AppColors.danger : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDanger ? AppColors.danger.withOpacity(0.06) : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
              ),
              if (showArrow) Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}