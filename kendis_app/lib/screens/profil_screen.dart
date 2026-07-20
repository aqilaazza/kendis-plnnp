import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      (user?.nama.isNotEmpty == true ? user!.nama[0] : 'D').toUpperCase(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.nama ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text(user?.nid ?? '-', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Driver', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('AKUN'),
            _menuCard([
              _MenuTile(icon: Icons.person_outline, label: 'Edit Profil', onTap: () {}),
              _MenuTile(icon: Icons.lock_reset_outlined, label: 'Ganti Password', onTap: () {}),
              _MenuTile(icon: Icons.notifications_none_outlined, label: 'Pengaturan Notifikasi', onTap: () {}),
            ]),
            const SizedBox(height: 20),

            _sectionLabel('LAINNYA'),
            _menuCard([
              _MenuTile(icon: Icons.help_outline, label: 'Pusat Bantuan', onTap: () {}),
              _MenuTile(icon: Icons.info_outline, label: 'Tentang Aplikasi', onTap: () {}),
              _MenuTile(
                icon: Icons.logout,
                label: 'Keluar',
                isDanger: true,
                onTap: () => _confirmLogout(context),
              ),
            ]),
            const SizedBox(height: 24),

            Center(
              child: Text('Kendis Driver App v1.0.0\n© 2026 PLN Nusantara Power.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6)),
      );

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.danger : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: (isDanger ? AppColors.danger : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500))),
            if (!isDanger) const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
