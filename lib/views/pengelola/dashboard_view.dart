import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pengelola/dashboard_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/pengelolaan_sampah_model.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

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
              // AppBar custom
              SliverToBoxAdapter(child: _buildHeader()),

              // Statistik cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Obx(() => _buildStatistikRow()),
                ),
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _buildQuickActions(),
                ),
              ),

              // Aktivitas terbaru
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: SectionHeader(
                    title: 'Aktivitas Terbaru',
                    actionLabel: 'Lihat Semua',
                    onAction: () => Get.toNamed(AppRoutes.historiSampah),
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
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: EmptyState(
                        icon: Icons.inbox_outlined,
                        message:
                            'Belum ada data sampah.\nMulai input data sekarang!',
                        actionLabel: 'Input Data',
                        onAction: () => Get.toNamed(AppRoutes.inputSampah),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = controller.aktivitasTerbaru[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _AktivitasCard(item: item),
                    );
                  }, childCount: controller.aktivitasTerbaru.length),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),

      // FAB input data
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.inputSampah),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Input Data',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.bankSampahNama,
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    'Halo, ${controller.penggunaNama}',
                    style: AppTextStyles.bodyMd,
                  ),
                ),
              ],
            ),
          ),
          // Profil bank sampah
          IconButton(
            icon: const Icon(Icons.store_outlined),
            onPressed: () => Get.toNamed(AppRoutes.profilBankSampah),
            tooltip: 'Profil Bank Sampah',
          ),
          // Ganti bank sampah
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => Get.toNamed(AppRoutes.pilihBankSampah),
            tooltip: 'Ganti Bank Sampah',
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.outline),
            onPressed: () => Get.find<AuthController>().logout(),
            tooltip: 'Keluar',
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Bulan Ini',
            value: FormatHelper.number(controller.totalJumlahBulanIni.value),
            satuan: 'kg',
            icon: Icons.scale_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Transaksi',
            value: controller.totalTransaksiBulanIni.value.toString(),
            satuan: 'entri',
            icon: Icons.receipt_long_outlined,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Nilai',
            value: FormatHelper.currency(controller.totalNilaiBulanIni.value),
            satuan: '',
            icon: Icons.payments_outlined,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Menu', style: AppTextStyles.titleMd),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline_rounded,
                label: 'Input Data',
                onTap: () => Get.toNamed(AppRoutes.inputSampah),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.history_rounded,
                label: 'Histori',
                onTap: () => Get.toNamed(AppRoutes.historiSampah),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.sell_outlined,
                label: 'Harga',
                onTap: () => Get.toNamed(AppRoutes.hargaSampah),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.store_outlined,
                label: 'Profil',
                onTap: () => Get.toNamed(AppRoutes.profilBankSampah),
              ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (satuan.isNotEmpty) Text(satuan, style: AppTextStyles.labelSm),
          Text(label, style: AppTextStyles.labelSm, maxLines: 1),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
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
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSm,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AktivitasCard extends StatelessWidget {
  final PengelolaanSampahModel item;

  const _AktivitasCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: AppColors.onSecondaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaItem, style: AppTextStyles.titleMd),
                Text(item.breadcrumb, style: AppTextStyles.bodyMd),
                Text(
                  FormatHelper.dateFromString(
                    item.tanggalPengelolaan.toIso8601String(),
                  ),
                  style: AppTextStyles.labelSm,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FormatHelper.jumlahSatuan(item.jumlah, item.satuan?.singkatan),
                style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
              ),
              if (item.totalHarga != null && item.totalHarga! > 0)
                Text(
                  FormatHelper.currency(item.totalHarga),
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
