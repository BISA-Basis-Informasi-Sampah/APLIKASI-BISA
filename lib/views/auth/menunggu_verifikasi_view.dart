import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/services/session_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/profile_model.dart';

class MenungguVerifikasiView extends StatefulWidget {
  const MenungguVerifikasiView({super.key});

  @override
  State<MenungguVerifikasiView> createState() => _MenungguVerifikasiViewState();
}

class _MenungguVerifikasiViewState extends State<MenungguVerifikasiView> {
  bool _isChecking = false;

  Future<void> _cekStatus() async {
    final authUserId = SessionService.to.profile.value?.authUserId;
    if (authUserId == null) return;

    setState(() => _isChecking = true);
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableProfiles)
          .select()
          .eq('auth_user_id', authUserId)
          .single();

      final profile = ProfileModel.fromJson(data);
      SessionService.to.setProfile(profile);

      if (profile.isVerified) {
        Get.offAllNamed(AppRoutes.pilihBankSampah);
      } else {
        Get.snackbar(
          'Belum Diverifikasi',
          'Akun kamu belum disetujui kelurahan. Silakan hubungi kelurahan setempat.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal memeriksa status. Periksa koneksi internet kamu.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // Ilustrasi
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.onPrimaryContainer,
                  size: 44,
                ),
              ),
              const SizedBox(height: 28),

              // Judul
              Text(
                'Menunggu Verifikasi',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Nama pengguna + penjelasan
              Obx(() {
                final nama = SessionService.to.profile.value?.namaLengkap ?? '';
                return Text(
                  'Halo $nama,\n\nAkun kamu sudah terdaftar. Kelurahan perlu memverifikasi dan menghubungkan kamu ke bank sampah terlebih dahulu sebelum bisa menggunakan aplikasi.',
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                );
              }),
              const SizedBox(height: 12),

              // Info tambahan
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Setelah kelurahan menyetujui akunmu, tekan tombol "Cek Status" di bawah untuk masuk ke aplikasi.',
                        style: AppTextStyles.labelSm,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tombol cek status
              AppButton(
                label: 'Cek Status',
                icon: Icons.refresh_rounded,
                isLoading: _isChecking,
                onPressed: _cekStatus,
              ),
              const SizedBox(height: 12),

              // Keluar
              TextButton.icon(
                onPressed: () => Get.find<AuthController>().logout(),
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: AppColors.outline,
                ),
                label: Text(
                  'Keluar',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
