import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

class PilihBankSampahView extends GetView<SessionController> {
  const PilihBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: AppColors.onPrimaryContainer,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BISA',
                        style: AppTextStyles.titleLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Basis Informasi Sampah',
                        style: AppTextStyles.labelSm,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Logout
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.outline,
                    ),
                    onPressed: () => Get.find<AuthController>().logout(),
                    tooltip: 'Keluar',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sapa pengguna
              Obx(() {
                final nama = SessionService.to.profile.value?.namaLengkap ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat datang,', style: AppTextStyles.bodyMd),
                    Text(
                      nama,
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Pilih bank sampah yang ingin dikelola:',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 20),

              // List bank sampah
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingWidget();
                  }

                  if (controller.listBankSampah.isEmpty) {
                    return EmptyState(
                      icon: Icons.store_outlined,
                      message:
                          'Kamu belum terhubung ke bank sampah manapun.\nHubungi kelurahan untuk mendapat akses.',
                      actionLabel: 'Muat Ulang',
                      onAction: controller.fetchBankSampahSaya,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchBankSampahSaya,
                    color: AppColors.primary,
                    child: ListView.separated(
                      itemCount: controller.listBankSampah.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final bank = controller.listBankSampah[index];
                        return _BankSampahCard(
                          bank: bank,
                          onTap: () => controller.pilihBankSampah(bank),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankSampahCard extends StatelessWidget {
  final BankSampahModel bank;
  final VoidCallback onTap;

  const _BankSampahCard({required this.bank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.nama, style: AppTextStyles.titleMd),
                if (bank.rt != null || bank.alamat != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (bank.rt != null) 'RT ${bank.rt}',
                      if (bank.rw != null) 'RW ${bank.rw}',
                      if (bank.alamat != null) bank.alamat!,
                    ].join(' • '),
                    style: AppTextStyles.bodyMd,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip.active(),
              if (!bank.isActive) StatusChip.inactive(),
              const SizedBox(height: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.outline,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
