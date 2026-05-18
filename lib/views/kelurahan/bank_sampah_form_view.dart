import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class BankSampahFormView extends GetView<BankSampahController> {
  const BankSampahFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode ? 'Edit Bank Sampah' : 'Tambah Bank Sampah',
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Informasi dasar ──────────────────────────
            _SectionCard(
              title: 'Informasi Bank Sampah',
              child: Column(
                children: [
                  AppTextField(
                    controller: controller.namaController,
                    label: 'Nama Bank Sampah *',
                    hint: 'Contoh: Bank Sampah RT 05',
                    prefixIcon: Icons.store_outlined,
                    validator: (v) =>
                        AppValidator.required(v, fieldName: 'Nama'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.alamatController,
                    label: 'Alamat (opsional)',
                    hint: 'Masukkan alamat lengkap',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Wilayah RT/RW ────────────────────────────
            _SectionCard(
              title: 'Wilayah',
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.rtController,
                      label: 'RT (opsional)',
                      hint: 'Contoh: 05',
                      prefixIcon: Icons.home_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: controller.rwController,
                      label: 'RW (opsional)',
                      hint: 'Contoh: 02',
                      prefixIcon: Icons.home_work_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Status aktif ─────────────────────────────
            _SectionCard(
              title: 'Status',
              child: Obx(() => Row(
                    children: [
                      const Icon(Icons.toggle_on_outlined,
                          color: AppColors.outline, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status Aktif',
                                style: AppTextStyles.bodyLg),
                            Text(
                              controller.isAktif.value
                                  ? 'Bank sampah sedang beroperasi'
                                  : 'Bank sampah tidak aktif',
                              style: AppTextStyles.bodyMd,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: controller.isAktif.value,
                        onChanged: (v) => controller.isAktif.value = v,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 16),

            // ── Pengelola yang terhubung (edit mode) ─────
            Obx(() {
              if (!controller.isEditMode) return const SizedBox.shrink();
              return Column(
                children: [
                  _SectionCard(
                    title: 'Pengelola Terhubung',
                    child: controller.listPengelolaTerhubung.isEmpty
                        ? Row(
                            children: [
                              const Icon(Icons.person_off_outlined,
                                  color: AppColors.outline, size: 20),
                              const SizedBox(width: 8),
                              Text('Belum ada pengelola terhubung',
                                  style: AppTextStyles.bodyMd),
                            ],
                          )
                        : Column(
                            children: controller.listPengelolaTerhubung
                                .map((p) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .secondaryContainer,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.person_rounded,
                                                size: 18,
                                                color: AppColors
                                                    .onSecondaryContainer),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(p.namaLengkap,
                                                style:
                                                    AppTextStyles.bodyLg),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.link_off_rounded,
                                                size: 18,
                                                color: AppColors.error),
                                            onPressed: () => controller
                                                .lepaskanPengelola(p),
                                            tooltip: 'Lepas pengelola',
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // ── Tombol simpan ─────────────────────────────
            Obx(() => AppButton(
                  label: controller.isEditMode
                      ? 'Simpan Perubahan'
                      : 'Buat Bank Sampah',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.simpan,
                  icon: Icons.save_rounded,
                )),
            const SizedBox(height: 12),
            AppButton(
              label: 'Batal',
              outlined: true,
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(title, style: AppTextStyles.titleMd),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
