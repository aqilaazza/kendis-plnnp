import 'package:flutter/material.dart';

class PenugasanOverlayCard extends StatelessWidget {
  final String kodeRequest;
  final String titikJemput;
  final String tujuanAkhir;
  final String jadwal;
  final bool urgent;
  final VoidCallback onTerima;
  final VoidCallback onDismiss;

  const PenugasanOverlayCard({
    super.key,
    required this.kodeRequest,
    required this.titikJemput,
    required this.tujuanAkhir,
    required this.jadwal,
    this.urgent = false,
    required this.onTerima,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop gelap transparan, menutupi seluruh layar
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(color: Colors.black54),
          ),
        ),
        // Card di tengah layar
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon lingkaran
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EAF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.work_outline, color: Color(0xFF1A1A2E), size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Penugasan Baru!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Segera konfirmasi ketersediaan Anda',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Box info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('KODE REQUEST',
                                style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
                            if (urgent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('URGENT',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(kodeRequest,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),

                        _infoRow(Icons.circle, Colors.green, 'Titik Jemput', titikJemput),
                        const SizedBox(height: 10),
                        _infoRow(Icons.circle_outlined, Colors.red, 'Tujuan Akhir', tujuanAkhir),
                        const SizedBox(height: 10),
                        _infoRow(Icons.calendar_today, Colors.blueGrey, 'Jadwal', jadwal),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D7377),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onTerima,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text('Terima Tugas', style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, Color iconColor, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(icon, size: 10, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}