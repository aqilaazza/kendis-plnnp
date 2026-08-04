import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/faq_service.dart';

class PusatBantuanScreen extends StatefulWidget {
  const PusatBantuanScreen({super.key});

  @override
  State<PusatBantuanScreen> createState() => _PusatBantuanScreenState();
}

class _PusatBantuanScreenState extends State<PusatBantuanScreen> {
  final _searchController = TextEditingController();

  List<FaqModel> _faqs = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===================================================================
  // LOAD FAQ DARI API
  // ===================================================================

  Future<void> _loadFaqs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final list = await FaqService.getList();
      if (!mounted) return;
      setState(() {
        _faqs = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ===================================================================
  // BUILD
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(context),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INTRO
                    _buildIntro(),
                    const SizedBox(height: 20),

                    // SEARCH
                    _buildSearchField(),
                    const SizedBox(height: 24),

                    // FAQ
                    _sectionLabel('PERTANYAAN UMUM'),
                    const SizedBox(height: 8),
                    _buildFaqSection(),
                    const SizedBox(height: 24),

                    // HUBUNGI ADMIN
                    _buildAdminSection(),
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
            'Pusat Bantuan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // INTRO
  // ===================================================================

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.support_agent_outlined, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ada yang bisa kami bantu?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan jawaban dari pertanyaan yang sering diajukan atau hubungi admin '
                  'jika membutuhkan bantuan.',
                  style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // SEARCH FIELD
  // ===================================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Cari pertanyaan atau bantuan...',
        hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search, size: 22, color: AppColors.textMuted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  // ===================================================================
  // FAQ SECTION (LOADING / ERROR / KONTEN)
  // ===================================================================

  Widget _buildFaqSection() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_hasError) return _buildFaqErrorState();

    return _buildFaqCard();
  }

  // ===================================================================
  // FAQ CARD
  // ===================================================================

  Widget _buildFaqCard() {
    final searchQuery = _searchController.text.toLowerCase().trim();

    final filteredFaqs = _faqs.where((faq) {
      return faq.pertanyaan.toLowerCase().contains(searchQuery) ||
          faq.jawaban.toLowerCase().contains(searchQuery);
    }).toList();

    if (filteredFaqs.isEmpty) return _buildEmptySearch();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: List.generate(filteredFaqs.length, (index) {
          final faq = filteredFaqs[index];
          return _buildFaqItem(
            question: faq.pertanyaan,
            answer: faq.jawaban,
            isLast: index == filteredFaqs.length - 1,
          );
        }),
      ),
    );
  }

  // ===================================================================
  // FAQ ITEM
  // ===================================================================

  Widget _buildFaqItem({required String question, required String answer, required bool isLast}) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: AppColors.primary.withOpacity(0.04),
        highlightColor: AppColors.primary.withOpacity(0.02),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,
          title: Text(
            question,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // EMPTY SEARCH
  // ===================================================================

  Widget _buildEmptySearch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Pertanyaan tidak ditemukan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba gunakan kata kunci yang berbeda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // FAQ ERROR STATE
  // ===================================================================

  Widget _buildFaqErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 32, color: AppColors.danger.withOpacity(0.7)),
          const SizedBox(height: 10),
          const Text(
            'Gagal memuat pertanyaan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Periksa koneksi internet Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: _loadFaqs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Coba Lagi', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Judul section + kartu kontak admin (gaya tile, sama seperti menu lain)
  // ---------------------------------------------------------------------

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('BUTUH BANTUAN LAIN?'),
        const SizedBox(height: 8),
        _buildAdminCard(),
      ],
    );
  }

  Widget _buildAdminCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: _buildContactItem(
        icon: Icons.support_agent_outlined,
        title: 'Hubungi Admin',
        subtitle: 'Dapatkan bantuan dari admin aplikasi',
        onTap: () {
          // TODO: arahkan ke WhatsApp / telepon admin (menyusul, dari database kontak_admin)
        },
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // SECTION LABEL
  // ===================================================================

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.6),
      ),
    );
  }
}