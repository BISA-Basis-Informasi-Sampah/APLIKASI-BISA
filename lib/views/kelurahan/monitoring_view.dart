import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/monitoring_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Monitoring Bank Sampah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.filter_list_rounded),
                  if (controller.filterAktifSaja.value)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => _showFilterSheet(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + periode ringkasan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                AppTextField(
                  controller: controller.searchController,
                  label: 'Cari bank sampah...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: controller.onSearch,
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            onPressed: controller.clearSearch,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 10),
                // Ringkasan global
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _RingkasanItem(
                          label: 'Bank Sampah',
                          value: '${controller.listBankFiltered.length}',
                        ),
                        _RingkasanItem(
                          label: 'Total Sampah',
                          value: FormatHelper.number(
                            controller.totalSampahGlobal.value,
                          ),
                          satuan: 'kg',
                        ),
                        _RingkasanItem(
                          label: 'Total Nilai',
                          value: FormatHelper.currency(
                            controller.totalNilaiGlobal.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // List bank sampah
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              if (controller.listBankFiltered.isEmpty) {
                return EmptyState(
                  icon: Icons.store_outlined,
                  message: 'Tidak ada bank sampah ditemukan.',
                  actionLabel: controller.filterAktifSaja.value
                      ? 'Tampilkan Semua'
                      : null,
                  onAction: controller.filterAktifSaja.value
                      ? () => controller.filterAktifSaja.value = false
                      : null,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchMonitoring,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: controller.listBankFiltered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bank = controller.listBankFiltered[index];
                    final stat = controller.statistikPerBank[bank.id];
                    return _MonitoringCard(
                      bank: bank,
                      totalJumlah: stat?['total_jumlah'] ?? 0,
                      totalTransaksi: stat?['total_transaksi'] ?? 0,
                      totalNilai: stat?['total_nilai'] ?? 0,
                      onTap: () {
                        controller.selectBank(bank);
                        Get.toNamed(AppRoutes.detailBankSampah);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filter', style: AppTextStyles.titleLg),
            const SizedBox(height: 20),
            Obx(
              () => SwitchListTile(
                value: controller.filterAktifSaja.value,
                onChanged: (v) => controller.filterAktifSaja.value = v,
                title: Text(
                  'Tampilkan aktif saja',
                  style: AppTextStyles.bodyLg,
                ),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Terapkan', onPressed: () => Get.back()),
          ],
        ),
      ),
    );
  }
}

class _MonitoringCard extends StatelessWidget {
  final BankSampahModel bank;
  final num totalJumlah;
  final num totalTransaksi;
  final num totalNilai;
  final VoidCallback onTap;

  const _MonitoringCard({
    required this.bank,
    required this.totalJumlah,
    required this.totalTransaksi,
    required this.totalNilai,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bank.isActive
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: bank.isActive
                      ? AppColors.onSecondaryContainer
                      : AppColors.outline,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bank.nama, style: AppTextStyles.titleMd),
                    if (bank.rt != null)
                      Text(
                        'RT ${bank.rt}${bank.rw != null ? ' / RW ${bank.rw}' : ''}',
                        style: AppTextStyles.bodyMd,
                      ),
                  ],
                ),
              ),
              bank.isActive ? StatusChip.active() : StatusChip.inactive(),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.outline,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.scale_outlined,
                label: 'Bulan Ini',
                value: '${FormatHelper.number(totalJumlah)} kg',
              ),
              _StatItem(
                icon: Icons.receipt_long_outlined,
                label: 'Transaksi',
                value: totalTransaksi.toString(),
              ),
              _StatItem(
                icon: Icons.payments_outlined,
                label: 'Nilai',
                value: FormatHelper.currency(totalNilai),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.outline),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }
}

class _RingkasanItem extends StatelessWidget {
  final String label;
  final String value;
  final String? satuan;

  const _RingkasanItem({required this.label, required this.value, this.satuan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
            ),
            if (satuan != null) ...[
              const SizedBox(width: 2),
              Text(satuan!, style: AppTextStyles.labelSm),
            ],
          ],
        ),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }
}
