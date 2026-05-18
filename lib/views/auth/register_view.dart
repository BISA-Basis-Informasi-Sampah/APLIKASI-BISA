import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

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
                      // Header
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
                              'Buat akun pengelola bank sampah',
                              style: AppTextStyles.bodyMd,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Nama lengkap
                      AppTextField(
                        controller: controller.namaController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        prefixIcon: Icons.badge_outlined,
                        validator: (v) =>
                            AppValidator.required(v, fieldName: 'Nama lengkap'),
                      ),
                      const SizedBox(height: 16),

                      // No HP (opsional)
                      AppTextField(
                        controller: controller.noHpController,
                        label: 'No. HP (opsional)',
                        hint: 'Contoh: 08123456789',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: AppValidator.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      AppTextField(
                        controller: controller.registerEmailController,
                        label: 'Email',
                        hint: 'Masukkan email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidator.email,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Obx(
                        () => AppTextField(
                          controller: controller.registerPasswordController,
                          label: 'Kata Sandi',
                          hint: 'Minimal 6 karakter',
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

                      // Konfirmasi password
                      Obx(
                        () => AppTextField(
                          controller: controller.confirmPasswordController,
                          label: 'Konfirmasi Kata Sandi',
                          hint: 'Ulangi kata sandi',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText:
                              !controller.isConfirmPasswordVisible.value,
                          validator: (v) => AppValidator.confirmPassword(
                            v,
                            controller.registerPasswordController.text,
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

                      // Tombol daftar
                      Obx(
                        () => AppButton(
                          label: 'Daftar Sekarang',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.register,
                          icon: Icons.check_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sudah punya akun
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
