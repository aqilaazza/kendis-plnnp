import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_nidController.text.trim(), _passwordController.text);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.backgroundAlt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo & Branding
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kendis',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistem Manajemen Kendaraan Dinas',
                      style: TextStyle(fontSize: 14, color: AppColors.textBody),
                    ),
                    const SizedBox(height: 32),

                    // Login Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Silakan masuk dengan akun PLN Nusantara Power Anda.',
                            style: TextStyle(fontSize: 13, color: AppColors.textBody.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('Username'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nidController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan NID atau Username',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Password'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Masukkan Password Anda',
                              prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            onSubmitted: (_) => _handleLogin(),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Text(
                                'Lupa Password?',
                                style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Masuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 18),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 12, color: AppColors.textBody),
                                children: [
                                  const TextSpan(text: 'Kendala saat masuk? '),
                                  TextSpan(
                                    text: 'Butuh Bantuan',
                                    style: TextStyle(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '© 2026 PLN Nusantara Power. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: 0.6),
    );
  }
}
