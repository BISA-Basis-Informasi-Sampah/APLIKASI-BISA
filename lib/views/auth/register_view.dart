import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    // Muat daftar bank sampah saat halaman dibuka
    controller.fetchBankSampahUntukRegister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: controller.registerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ───────────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLg,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_add_rounded,
                                color: AppColors.onPrimaryContainer,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Daftar Akun',
                              style: AppTextStyles.headlineMd.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Daftar dan tunggu verifikasi kelurahan',
                              style: AppTextStyles.bodyMd,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Info verifikasi ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          border: Border.all(
                            color: AppColors.outlineVariant.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: AppColors.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Setelah mendaftar, akun kamu akan diverifikasi oleh kelurahan sebelum bisa digunakan.',
                                style: AppTextStyles.labelSm,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Data diri ────────────────────────────────────
                      AppTextField(
                        controller: controller.regNamaController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        prefixIcon: Icons.badge_outlined,
                        validator: (v) =>
                            AppValidator.required(v, fieldName: 'Nama lengkap'),
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: controller.regNoHpController,
                        label: 'No. HP (opsional)',
                        hint: 'Contoh: 08123456789',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: AppValidator.phone,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: controller.regEmailController,
                        label: 'Email',
                        hint: 'Masukkan email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidator.email,
                      ),
                      const SizedBox(height: 16),

                      Obx(
                        () => AppTextField(
                          controller: controller.regPasswordController,
                          label: 'Kata Sandi',
                          hint: 'Minimal 8 karakter',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: !controller.isPasswordVisible.value,
                          validator: AppValidator.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.outline,
                              size: 20,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Obx(
                        () => AppTextField(
                          controller: controller.regConfirmPasswordController,
                          label: 'Konfirmasi Kata Sandi',
                          hint: 'Ulangi kata sandi',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText:
                              !controller.isConfirmPasswordVisible.value,
                          validator: (v) => AppValidator.confirmPassword(
                            v,
                            controller.regPasswordController.text,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.outline,
                              size: 20,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Pilih bank sampah ────────────────────────────
                      Text(
                        'Bank Sampah yang Ingin Dikelola',
                        style: AppTextStyles.titleMd,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih bank sampah tempat kamu akan bertugas. Kelurahan akan memverifikasi pilihanmu.',
                        style: AppTextStyles.bodyMd,
                      ),
                      const SizedBox(height: 12),

                      Obx(() {
                        if (controller.isLoadingBankSampah.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (controller.listBankSampahRegister.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLow,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                              border: Border.all(
                                color: AppColors.outlineVariant.withOpacity(
                                  0.4,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.store_outlined,
                                  size: 16,
                                  color: AppColors.outline,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Belum ada bank sampah tersedia.',
                                  style: AppTextStyles.bodyMd,
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLowest,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.outlineVariant.withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            children: controller.listBankSampahRegister.map((
                              bank,
                            ) {
                              return Obx(
                                () => CheckboxListTile(
                                  title: Text(
                                    bank.namaLengkap,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  subtitle: bank.alamat != null
                                      ? Text(
                                          bank.alamat!,
                                          style: AppTextStyles.labelSm,
                                        )
                                      : null,
                                  value: controller.selectedBankSampahRegister
                                      .contains(bank.id),
                                  onChanged: (v) {
                                    if (v == true) {
                                      controller.selectedBankSampahRegister.add(
                                        bank.id,
                                      );
                                    } else {
                                      controller.selectedBankSampahRegister
                                          .remove(bank.id);
                                    }
                                  },
                                  activeColor: AppColors.primary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  dense: true,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // ── Tombol daftar ────────────────────────────────
                      Obx(
                        () => AppButton(
                          label: 'Daftar Sekarang',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.register,
                          icon: Icons.check_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Link login ───────────────────────────────────
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun? ',
                              style: AppTextStyles.bodyMd,
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Text(
                                'Masuk',
                                style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}