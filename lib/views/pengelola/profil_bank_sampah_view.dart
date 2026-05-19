import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/services/supabase_service.dart';

class ProfilBankSampahView extends StatelessWidget {
  const ProfilBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Bank Sampah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Hero card bank sampah ────────────────────
          Obx(() {
            final bank = session.activeBankSampah.value;
            if (bank == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.secondary, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(Icons.store_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bank.nama,
                                style: AppTextStyles.titleLg
                                    .copyWith(color: Colors.white)),
                            if (bank.rt != null || bank.rw != null)
                              Text(
                                [
                                  if (bank.rt != null) 'RT ${bank.rt}',
                                  if (bank.rw != null) 'RW ${bank.rw}',
                                ].join(' / '),
                                style: AppTextStyles.bodyMd
                                    .copyWith(color: Colors.white70),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bank.isActive
                              ? Colors.white.withOpacity(0.2)
                              : Colors.red.withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          bank.isActive ? 'Aktif' : 'Nonaktif',
                          style: AppTextStyles.labelSm
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if (bank.alamat != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(bank.alamat!,
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Bergabung ${FormatHelper.date(bank.createdAt)}',
                    style: AppTextStyles.labelSm
                        .copyWith(color: Colors.white54),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // ── Profil pengelola ─────────────────────────
          Obx(() {
            final profil = session.profile.value;
            if (profil == null) return const SizedBox.shrink();
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengelola', style: AppTextStyles.titleMd),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Nama',
                    value: profil.namaLengkap,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: SupabaseService.currentUser?.email ?? '-',
                  ),
                  if (profil.noHp != null) ...[
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'No. HP',
                      value: profil.noHp!,
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // ── Menu navigasi cepat ───────────────────────
          AppCard(
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.history_rounded,
                  label: 'Histori Pengelolaan',
                  onTap: () => Get.toNamed(AppRoutes.historiSampah),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Ganti Bank Sampah',
                  onTap: () => Get.toNamed(AppRoutes.pilihBankSampah),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Logout ────────────────────────────────────
          AppButton(
            label: 'Keluar dari Akun',
            outlined: true,
            icon: Icons.logout_rounded,
            onPressed: () => Get.find<AuthController>().logout(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

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
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSm),
            Text(value, style: AppTextStyles.bodyLg),
          ],
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTextStyles.bodyLg),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.outline, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      dense: true,
    );
  }
}