import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/kelurahan/dashboard_kelurahan_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';

class DashboardKelurahanView extends GetView<DashboardKelurahanController> {
  const DashboardKelurahanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Stat cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _buildStatGrid(),
                ),
              ),

              // Menu kelurahan
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _buildMenuGrid(),
                ),
              ),

              // Aktivitas terbaru
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: SectionHeader(
                    title: 'Aktivitas Terbaru',
                    actionLabel: 'Monitoring',
                    onAction: () => Get.toNamed(AppRoutes.monitoringBankSampah),
                  ),
                ),
              ),

              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: LoadingWidget(),
                    ),
                  );
                }
                if (controller.aktivitasTerbaru.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: EmptyState(
                        icon: Icons.inbox_outlined,
                        message: 'Belum ada aktivitas pengelolaan.',
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = controller.aktivitasTerbaru[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _AktivitasKelurahanCard(item: item),
                    );
                  }, childCount: controller.aktivitasTerbaru.length),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BISA',
                      style: AppTextStyles.titleLg.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Dashboard Kelurahan',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Get.toNamed(AppRoutes.profilKelurahan),
                tooltip: 'Profil',
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                onPressed: () => Get.find<AuthController>().logout(),
                tooltip: 'Keluar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Selamat datang, ${controller.penggunaNama}',
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
          ),
          Text(
            controller.namaKelurahan,
            style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Obx(
          () => _StatCard(
            label: 'Total Sampah\nBulan Ini',
            value: FormatHelper.number(controller.totalJumlahBulanIni.value),
            satuan: 'kg',
            icon: Icons.scale_outlined,
            color: AppColors.primary,
          ),
        ),
        Obx(
          () => _StatCard(
            label: 'Bank Sampah\nAktif',
            value: controller.totalBankSampahAktif.value.toString(),
            satuan: 'unit',
            icon: Icons.store_rounded,
            color: AppColors.secondary,
          ),
        ),
        Obx(
          () => _StatCard(
            label: 'Total Transaksi\nBulan Ini',
            value: controller.totalTransaksiBulanIni.value.toString(),
            satuan: 'entri',
            icon: Icons.receipt_long_outlined,
            color: AppColors.info,
          ),
        ),
        Obx(
          () => _StatCard(
            label: 'Nilai Total\nBulan Ini',
            value: FormatHelper.currency(controller.totalNilaiBulanIni.value),
            satuan: '',
            icon: Icons.payments_outlined,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Menu Kelurahan', style: AppTextStyles.titleMd),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _MenuCard(
              icon: Icons.bar_chart_rounded,
              label: 'Monitoring',
              onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
            ),
            _MenuCard(
              icon: Icons.store_rounded,
              label: 'Bank Sampah',
              onTap: () => Get.toNamed(AppRoutes.manajemenBankSampah),
            ),
            _MenuCard(
              icon: Icons.people_outline_rounded,
              label: 'Pengelola',
              onTap: () => Get.toNamed(AppRoutes.manajemenPengelola),
            ),
            _MenuCard(
              icon: Icons.category_outlined,
              label: 'Master Sampah',
              onTap: () => Get.toNamed(AppRoutes.masterSampah),
            ),
            _MenuCard(
              icon: Icons.assessment_outlined,
              label: 'Laporan',
              onTap: () => Get.toNamed(AppRoutes.generatorLaporan),
            ),
            _MenuCard(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              onTap: () => Get.toNamed(AppRoutes.profilKelurahan),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String satuan;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.satuan,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.titleMd.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (satuan.isNotEmpty) Text(satuan, style: AppTextStyles.labelSm),
              Text(label, style: AppTextStyles.labelSm, maxLines: 2),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: AppColors.onPrimaryContainer, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSm,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _AktivitasKelurahanCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _AktivitasKelurahanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: AppColors.onSecondaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['bank_nama'] ?? '-', style: AppTextStyles.titleMd),
                Text(item['jenis_nama'] ?? '-', style: AppTextStyles.bodyMd),
                Text(
                  FormatHelper.dateFromString(item['tanggal'] ?? ''),
                  style: AppTextStyles.labelSm,
                ),
              ],
            ),
          ),
          Text(
            FormatHelper.jumlahSatuan(item['jumlah'], item['satuan_singkatan']),
            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
