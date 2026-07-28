import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_nav/main_nav_screen.dart';

void main() {
  runApp(const KendisDriverApp());
}

class KendisDriverApp extends StatelessWidget {
  const KendisDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLoginStatus()),
      ],
      child: MaterialApp(
        title: 'Kendis Driver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashGate(),
      ),
    );
  }
}

/// Menentukan halaman awal: Login atau MainNav, berdasarkan status sesi tersimpan.
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.unknown:
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.loggedIn:
            return const MainNavScreen();
          case AuthStatus.loggedOut:
            return const LoginScreen();
        }
      },
    );
  }
}
