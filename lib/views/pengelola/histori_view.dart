import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/pengelola/histori_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/pengelolaan_sampah_model.dart';

class HistoriView extends GetView<HistoriController> {
  const HistoriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Histori Pengelolaan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Filter
          Obx(
            () => IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.filter_list_rounded),
                  if (controller.isFilterActive)
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
              tooltip: 'Filter',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppTextField(
              controller: controller.searchController,
              label: 'Cari data...',
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
          ),

          // Summary bar
          Obx(() {
            if (controller.listHistori.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Total Entri',
                      value: '${controller.listHistori.length}',
                    ),
                    _SummaryItem(
                      label: 'Total Nilai',
                      value: FormatHelper.currency(controller.totalNilai),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget();
              }
              if (controller.listHistori.isEmpty) {
                return EmptyState(
                  icon: Icons.history_rounded,
                  message: controller.searchQuery.value.isNotEmpty
                      ? 'Data tidak ditemukan.'
                      : 'Belum ada data pengelolaan.',
                  actionLabel: controller.isFilterActive
                      ? 'Reset Filter'
                      : null,
                  onAction: controller.isFilterActive
                      ? controller.resetFilter
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchHistori,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: controller.listHistori.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = controller.listHistori[index];
                    return _HistoriCard(
                      item: item,
                      onEdit: () => controller.editItem(item),
                      onDelete: () => controller.deleteItem(item),
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
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (_) => _FilterSheet(controller: controller),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final HistoriController controller;

  const _FilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          Text('Filter Data', style: AppTextStyles.titleLg),
          const SizedBox(height: 20),

          // Filter kategori
          Text('Kategori', style: AppTextStyles.labelLg),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'Semua',
                  isSelected: controller.filterKategoriId.value.isEmpty,
                  onTap: () => controller.filterKategoriId.value = '',
                ),
                ...controller.listKategoriFilter.map(
                  (k) => _FilterChip(
                    label: k.nama,
                    isSelected: controller.filterKategoriId.value == k.id,
                    onTap: () => controller.filterKategoriId.value = k.id,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter tanggal
          Text('Periode', style: AppTextStyles.labelLg),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _DatePickerField(
                    label: 'Dari Tanggal',
                    value: controller.filterTanggalMulai.value,
                    onTap: () => controller.pickTanggalMulai(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _DatePickerField(
                    label: 'Sampai Tanggal',
                    value: controller.filterTanggalAkhir.value,
                    onTap: () => controller.pickTanggalAkhir(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reset',
                  outlined: true,
                  onPressed: () {
                    controller.resetFilter();
                    Get.back();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Terapkan',
                  onPressed: () {
                    controller.applyFilter();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoriCard extends StatelessWidget {
  final PengelolaanSampahModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HistoriCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: AppColors.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.namaItem, style: AppTextStyles.titleMd),
                    Text(
                      item.breadcrumb,
                      style: AppTextStyles.bodyMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Menu aksi
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.outline,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.onSurface,
                        ),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                icon: Icons.scale_outlined,
                label: FormatHelper.jumlahSatuan(
                  item.jumlah,
                  item.satuan?.singkatan,
                ),
              ),
              if (item.totalHarga != null && item.totalHarga! > 0)
                _InfoChip(
                  icon: Icons.payments_outlined,
                  label: FormatHelper.currency(item.totalHarga),
                  color: AppColors.secondary,
                ),
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label: FormatHelper.dateFromString(
                  item.tanggalPengelolaan.toIso8601String(),
                ),
              ),
            ],
          ),
          if (item.catatan != null && item.catatan!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 14,
                  color: AppColors.outline,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.catatan!,
                    style: AppTextStyles.bodyMd,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.outline),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: color ?? AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMd.copyWith(
            color: AppColors.onSecondaryContainer,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.outline,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null ? FormatHelper.date(value) : label,
                style: value != null
                    ? AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface)
                    : AppTextStyles.bodyMd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
