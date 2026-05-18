import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/pengelola_controller.dart';
import '../../core/widgets/app_widgets.dart';

class PengelolaFormView extends GetView<PengelolaController> {
  const PengelolaFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Pengelola'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info header ─────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.infoContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Akun pengelola akan langsung aktif dan dapat digunakan untuk login.',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Data Akun ────────────────────────────────
              Text('Data Akun', style: AppTextStyles.titleMd),
              const SizedBox(height: 12),

              AppTextField(
                controller: controller.namaController,
                label: 'Nama Lengkap',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: controller.emailController,
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email wajib diisi';
                  if (!GetUtils.isEmail(v)) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Obx(
                () => AppTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.outline,
                    ),
                    onPressed: controller.togglePassword,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: controller.noHpController,
                label: 'No. HP (opsional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // ── Pilih Bank Sampah ────────────────────────
              Text('Bank Sampah yang Dikelola', style: AppTextStyles.titleMd),
              const SizedBox(height: 4),
              Text(
                'Pilih satu atau lebih bank sampah yang akan dikelola pengelola ini.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              Obx(() {
                if (controller.listBankSampah.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Belum ada bank sampah tersedia.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: controller.listBankSampah.map((bank) {
                      return Obx(
                        () => CheckboxListTile(
                          title: Text(
                            bank.namaLengkap,
                            style: AppTextStyles.bodyMd,
                          ),
                          subtitle: bank.alamat != null
                              ? Text(
                                  bank.alamat!,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                )
                              : null,
                          value: controller.selectedBankSampahIds.contains(
                            bank.id,
                          ),
                          onChanged: (v) {
                            if (v == true) {
                              controller.selectedBankSampahIds.add(bank.id);
                            } else {
                              controller.selectedBankSampahIds.remove(bank.id);
                            }
                          },
                          activeColor: AppColors.primary,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // ── Tombol Simpan ────────────────────────────
              Obx(
                () => AppButton(
                  label: 'Buat Akun Pengelola',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.tambahPengelola,
                  icon: Icons.person_add_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
