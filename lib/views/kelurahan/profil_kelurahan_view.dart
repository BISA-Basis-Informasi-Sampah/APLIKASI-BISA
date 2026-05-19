import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../controllers/auth_controller.dart';

class ProfilKelurahanView extends StatelessWidget {
  const ProfilKelurahanView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Kelurahan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Avatar & nama ────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Obx(() {
                    final nama =
                        session.profile.value?.namaLengkap ?? 'Kelurahan';
                    return Center(
                      child: Text(
                        nama.isNotEmpty ? nama[0].toUpperCase() : 'K',
                        style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    session.profile.value?.namaLengkap ?? '-',
                    style: AppTextStyles.titleLg,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    'Pengelola Kelurahan',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Informasi Akun ────────────────────────────────
          const SectionHeader(title: 'Informasi Akun'),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Obx(
                  () => _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Nama',
                    value: session.profile.value?.namaLengkap ?? '-',
                  ),
                ),
                const Divider(height: 1, indent: 54),
                Obx(
                  () => _InfoRow(
                    icon: Icons.people_outline_rounded,
                    label: 'Role',
                    value: 'Kelurahan',
                  ),
                ),
                const Divider(height: 1, indent: 54),
                Obx(
                  () => _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Bergabung',
                    value: session.profile.value?.createdAt != null
                        ? FormatHelper.date(session.profile.value!.createdAt)
                        : '-',
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Kelola ───────────────────────────────────
          const SizedBox(height: 24),
          const SectionHeader(title: 'Kelola Sistem'),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.store_rounded,
                  label: 'Manajemen Bank Sampah',
                  onTap: () => Get.toNamed(AppRoutes.manajemenBankSampah),
                ),
                const Divider(height: 1, indent: 54),
                _MenuRow(
                  icon: Icons.people_rounded,
                  label: 'Manajemen Pengelola',
                  onTap: () => Get.toNamed(AppRoutes.manajemenPengelola),
                ),
                const Divider(height: 1, indent: 54),
                _MenuRow(
                  icon: Icons.category_rounded,
                  label: 'Master Data Sampah',
                  onTap: () => Get.toNamed(AppRoutes.masterSampah),
                ),
                const Divider(height: 1, indent: 54),
                _MenuRow(
                  icon: Icons.description_rounded,
                  label: 'Generator Laporan',
                  onTap: () => Get.toNamed(AppRoutes.generatorLaporan),
                ),
              ],
            ),
          ),

          // ── Keluar ────────────────────────────────────────
          const SizedBox(height: 24),
          AppButton(
            label: 'Keluar dari Akun',
            outlined: true,
            icon: Icons.logout_rounded,
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
  final ok = await ConfirmDialog.show(
    title: 'Keluar',
    message: 'Yakin ingin keluar dari akun?',
    confirmLabel: 'Keluar',
    cancelLabel: 'Batal',
    isDanger: true,
  );
  if (ok) {
    // Gunakan AuthController.logout() agar auth.signOut() ikut dipanggil
    Get.find<AuthController>().logout();
    // JANGAN pakai manual clearSession + navigate karena
    // token Supabase masih aktif di memory
  }
}
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.outline),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
