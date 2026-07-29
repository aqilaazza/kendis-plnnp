import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/aktivitas_card.dart';
import 'widgets/biaya_card.dart';
import 'widgets/cost_chart_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/stats_duo_card.dart';
import 'widgets/top_cities_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _provider = DashboardProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(_onChanged);
    _provider.load();
  }

  @override
  void dispose() {
    _provider.removeListener(_onChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userName = user?.nama ?? 'Driver';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _provider.refresh,
          child: _buildBody(userName),
        ),
      ),
    );
  }

  Widget _buildBody(String userName) {
    final state = _provider.state;
    final data = _provider.data;
    final isLoading = state == DashboardLoadState.loading || state == DashboardLoadState.initial;

    if (state == DashboardLoadState.error) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Icon(Icons.cloud_off, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(_provider.errorMessage ?? 'Terjadi kesalahan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textBody, fontSize: 14)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _provider.refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        DashboardHeader(data: data, isLoading: isLoading, userName: userName),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              StatsDuoCard(data: data, isLoading: isLoading),
              const SizedBox(height: 16),
              BiayaCard(data: data, isLoading: isLoading),
              const SizedBox(height: 16),
              CostChartCard(data: data, isLoading: isLoading),
              const SizedBox(height: 16),
              TopCitiesCard(data: data, isLoading: isLoading),
              const SizedBox(height: 16),
              AktivitasCard(data: data, isLoading: isLoading),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
