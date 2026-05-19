import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

class BankSampahListView extends GetView<BankSampahController> {
  const BankSampahListView({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final isFabVisible = true.obs;

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isFabVisible.value) isFabVisible.value = false;
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isFabVisible.value) isFabVisible.value = true;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Bank Sampah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppTextField(
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
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();

              if (controller.listBankFiltered.isEmpty) {
                return EmptyState(
                  icon: Icons.store_outlined,
                  message: 'Belum ada bank sampah.',
                  actionLabel: 'Tambah Bank Sampah',
                  onAction: () {
                    controller.resetForm();
                    Get.toNamed(AppRoutes.formBankSampah);
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchBankSampah,
                color: AppColors.primary,
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: controller.listBankFiltered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bank = controller.listBankFiltered[index];
                    return _BankSampahCard(
                      bank: bank,
                      onEdit: () {
                        controller.initEdit(bank);
                        Get.toNamed(AppRoutes.formBankSampah);
                      },
                      onDelete: () => controller.deleteBank(bank),
                      onToggleActive: () => controller.toggleAktif(bank),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: isFabVisible.value ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isFabVisible.value ? 1.0 : 0.0,
            child: FloatingActionButton.extended(
              onPressed: () {
                controller.resetForm();
                Get.toNamed(AppRoutes.formBankSampah);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Tambah',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BankSampahCard extends StatelessWidget {
  final BankSampahModel bank;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _BankSampahCard({
    required this.bank,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
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
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.nama, style: AppTextStyles.titleMd),
                if (bank.rt != null || bank.rw != null)
                  Text(
                    [
                      if (bank.rt != null) 'RT ${bank.rt}',
                      if (bank.rw != null) 'RW ${bank.rw}',
                    ].join(' / '),
                    style: AppTextStyles.bodyMd,
                  ),
                if (bank.alamat != null)
                  Text(
                    bank.alamat!,
                    style: AppTextStyles.bodyMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                bank.isActive ? StatusChip.active() : StatusChip.inactive(),
              ],
            ),
          ),
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
              if (v == 'toggle') onToggleActive();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      bank.isActive
                          ? Icons.toggle_off_outlined
                          : Icons.toggle_on_outlined,
                      size: 18,
                      color: bank.isActive
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(bank.isActive ? 'Nonaktifkan' : 'Aktifkan'),
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
    );
  }
}