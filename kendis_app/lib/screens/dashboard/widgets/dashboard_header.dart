import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../models/dashboard_model.dart';
import '../../notifikasi/notifikasi_screen.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardModel? data;
  final bool isLoading;
  final String userName;

  const DashboardHeader({
    super.key,
    this.data,
    required this.isLoading,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(color: Color(0xFFF0F6FA)),
      child: Column(
        children: [
          // --- Baris atas: Foto profil, nama user, lonceng notifikasi ---
          // Data nama diambil dari tabel MySQL `users.name` yang sudah
          // dipetakan ke UserModel.nama di auth_provider.
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      // Buka halaman notifikasi. Setelah balik, refresh
                      // dashboard supaya badge count ke-update lagi
                      // (misal ada notifikasi yang baru ditandai dibaca).
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  // Badge notifikasi dari data['notifikasiUnread']
                  if (data?.notifikasiUnread != null &&
                      data!.notifikasiUnread! > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${data!.notifikasiUnread}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // --- Baris bawah: Ucapan salam dan info perusahaan ---
          // Data perusahaan & role berasal dari UserModel.company & .role
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Driver!',
                      style: TextStyle(
                        fontSize: isLoading ? 0 : 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isLoading) _skeleton(200, 14),
                    const SizedBox(height: 4),
                    Text(
                      'PLN Nusantara Power • Driver Operasional',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeleton(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}