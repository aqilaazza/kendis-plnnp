import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PusatBantuanScreen extends StatefulWidget {
  const PusatBantuanScreen({super.key});

  @override
  State<PusatBantuanScreen> createState() => _PusatBantuanScreenState();
}

class _PusatBantuanScreenState extends State<PusatBantuanScreen> {
  final TextEditingController _searchController = TextEditingController();

  // =========================================================================
  // DATA FAQ SEMENTARA
  // Nanti bisa diganti dengan data dari API
  // =========================================================================

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara melihat tugas yang diberikan?',
      'answer':
          'Tugas yang diberikan kepada Anda dapat dilihat melalui halaman Beranda. '
          'Pilih tugas yang ingin dilihat untuk membuka detail penugasan.',
    },
    {
      'question': 'Bagaimana cara memulai perjalanan?',
      'answer':
          'Buka detail tugas yang sedang aktif, kemudian ikuti instruksi yang tersedia '
          'pada halaman detail perjalanan.',
    },
    {
      'question': 'Bagaimana cara menyelesaikan tugas?',
      'answer':
          'Setelah perjalanan selesai, buka detail tugas dan lakukan proses penyelesaian '
          'sesuai dengan langkah yang tersedia pada aplikasi.',
    },
    {
      'question': 'Apa yang harus dilakukan jika terjadi kendala?',
      'answer':
          'Jika mengalami kendala saat menjalankan tugas, silakan hubungi admin atau '
          'pihak yang bertanggung jawab untuk mendapatkan bantuan lebih lanjut.',
    },
    {
      'question': 'Bagaimana cara mengubah nomor HP?',
      'answer':
          'Buka menu Profil, pilih Edit Profil, kemudian ubah nomor HP pada bagian '
          'Informasi Kontak dan tekan tombol Simpan Perubahan.',
    },
    {
      'question': 'Bagaimana cara mengganti password?',
      'answer':
          'Buka menu Profil, pilih Ganti Password, kemudian masukkan password lama '
          'dan password baru Anda.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  20,
                  18,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // INTRO
                    // =========================================================

                    _buildIntro(),

                    const SizedBox(height: 18),

                    // =========================================================
                    // SEARCH
                    // =========================================================

                    _buildSearchField(),

                    const SizedBox(height: 24),

                    // =========================================================
                    // FAQ
                    // =========================================================

                    _sectionLabel('PERTANYAAN UMUM'),

                    const SizedBox(height: 8),

                    _buildFaqCard(),

                    const SizedBox(height: 24),

                    // =========================================================
                    // HUBUNGI KAMI
                    // =========================================================

                    _sectionLabel('BUTUH BANTUAN LAIN?'),

                    const SizedBox(height: 8),

                    _buildContactCard(),
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
            'Pusat Bantuan',
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
  // INTRO
  // =========================================================================

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              size: 19,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ada yang bisa kami bantu?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Temukan jawaban dari pertanyaan yang sering diajukan '
                  'atau hubungi admin jika membutuhkan bantuan.',
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.5,
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

  // =========================================================================
  // SEARCH FIELD
  // =========================================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Cari pertanyaan atau bantuan...',
        hintStyle: TextStyle(
          fontSize: 10,
          color: AppColors.textMuted,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 19,
          color: AppColors.textMuted,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close,
                  size: 17,
                  color: AppColors.textMuted,
                ),
              )
            : null,
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
    );
  }

  // =========================================================================
  // FAQ CARD
  // =========================================================================

  Widget _buildFaqCard() {
    final searchQuery = _searchController.text.toLowerCase().trim();

    final filteredFaqs = _faqs.where((faq) {
      final question = faq['question']!.toLowerCase();
      final answer = faq['answer']!.toLowerCase();

      return question.contains(searchQuery) ||
          answer.contains(searchQuery);
    }).toList();

    if (filteredFaqs.isEmpty) {
      return _buildEmptySearch();
    }

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
        children: List.generate(
          filteredFaqs.length,
          (index) {
            final faq = filteredFaqs[index];

            return _buildFaqItem(
              question: faq['question']!,
              answer: faq['answer']!,
              isLast: index == filteredFaqs.length - 1,
            );
          },
        ),
      ),
    );
  }

  // =========================================================================
  // FAQ ITEM
  // =========================================================================

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isLast,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: AppColors.primary.withOpacity(0.04),
        highlightColor: AppColors.primary.withOpacity(0.02),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade100,
                    width: 1,
                  ),
                ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            12,
            0,
            12,
            12,
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,

          title: Text(
            question,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 9.5,
                  height: 1.6,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // EMPTY SEARCH
  // =========================================================================

  Widget _buildEmptySearch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 20,
      ),
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
          Icon(
            Icons.search_off_outlined,
            size: 32,
            color: AppColors.textMuted,
          ),

          const SizedBox(height: 10),

          const Text(
            'Pertanyaan tidak ditemukan',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Coba gunakan kata kunci yang berbeda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CONTACT CARD
  // =========================================================================

  Widget _buildContactCard() {
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
        children: [
          _buildContactItem(
            icon: Icons.support_agent_outlined,
            title: 'Hubungi Admin',
            subtitle: 'Dapatkan bantuan dari admin aplikasi',
            onTap: () {
              // TODO:
              // Nanti bisa diarahkan ke WhatsApp / telepon admin
            },
          ),

          Container(
            height: 1,
            color: Colors.grey.shade100,
          ),

          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Kirim Pesan',
            subtitle: 'Sampaikan pertanyaan atau kendala Anda',
            onTap: () {
              // TODO:
              // Nanti bisa diarahkan ke email atau form bantuan
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CONTACT ITEM
  // =========================================================================

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          child: Row(
            children: [
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
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

  // =========================================================================
  // SECTION LABEL
  // =========================================================================

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 0,
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
}