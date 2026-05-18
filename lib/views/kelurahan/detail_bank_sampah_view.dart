import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/monitoring_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/pengelolaan_sampah_model.dart';

class DetailBankSampahView extends GetView<MonitoringController> {
  const DetailBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedBankSampah.value?.namaLengkap ??
                'Detail Bank Sampah',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refresh,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Obx(() {
        final bank = controller.selectedBankSampah.value;
        if (bank == null) {
          return const EmptyState(
            icon: Icons.store_outlined,
            message: 'Bank sampah tidak ditemukan.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ── Info Bank Sampah ─────────────────────────
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  bank.nama,
                                  style: AppTextStyles.titleMd,
                                ),
                              ),
                              const SizedBox(width: 8),
                              bank.isActive
                                  ? StatusChip.active()
                                  : StatusChip.inactive(),
                            ],
                          ),
                          if (bank.rt != null || bank.rw != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'RT ${bank.rt ?? '-'} / RW ${bank.rw ?? '-'}',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (bank.alamat != null &&
                              bank.alamat!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              bank.alamat!,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Statistik Bulan Ini ───────────────────────
              const SizedBox(height: 20),
              const SectionHeader(title: 'Statistik Bulan Ini'),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Transaksi',
                        value: '${controller.statTransaksi.value}x',
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.info,
                        bgColor: AppColors.infoContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Jumlah',
                        value: FormatHelper.number(controller.statJumlah.value),
                        icon: Icons.scale_outlined,
                        color: AppColors.secondary,
                        bgColor: AppColors.secondaryContainer.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Nilai',
                        value: FormatHelper.currency(
                          controller.statNilai.value,
                        ),
                        icon: Icons.payments_outlined,
                        color: AppColors.primary,
                        bgColor: AppColors.onPrimaryContainer.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Riwayat Transaksi ─────────────────────────
              const SizedBox(height: 20),
              const SectionHeader(title: 'Riwayat Transaksi Bulan Ini'),
              const SizedBox(height: 10),

              Obx(() {
                if (controller.isLoadingDetail.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: LoadingWidget(),
                  );
                }
                if (controller.detailTransaksi.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'Belum ada transaksi bulan ini.',
                  );
                }
                return Column(
                  children: controller.detailTransaksi
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TransaksiCard(transaksi: t),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransaksiCard extends StatelessWidget {
  final PengelolaanSampahModel transaksi;
  const _TransaksiCard({required this.transaksi});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaksi.namaItem, style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(
                  '${FormatHelper.number(transaksi.jumlah)} ${transaksi.satuan?.singkatan ?? ''}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (transaksi.profile != null)
                  Text(
                    transaksi.profile!.namaLengkap,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (transaksi.totalHarga != null)
                Text(
                  FormatHelper.currency(transaksi.totalHarga),
                  style: AppTextStyles.titleMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                FormatHelper.date(transaksi.tanggalPengelolaan),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
