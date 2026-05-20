import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/pengelola_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';
import '../../models/profile_model.dart';

class PengelolaListView extends GetView<PengelolaController> {
  const PengelolaListView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Manajemen Pengelola'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Obx(() {
              final pendingCount = controller.listPending.length;
              return TabBar(
                tabs: [
                  const Tab(text: 'Aktif'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Menunggu'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.outline,
              );
            }),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const LoadingWidget();
          return TabBarView(
            children: [
              _TabAktif(controller: controller),
              _TabPending(controller: controller),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            controller.resetForm();
            Get.toNamed(AppRoutes.formPengelola);
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon: const Icon(Icons.person_add_rounded),
          label: Text(
            'Tambah',
            style: AppTextStyles.labelLg.copyWith(color: AppColors.onPrimary),
          ),
        ),
      ),
    );
  }
}

// ── Tab Pengelola Aktif ────────────────────────────────────────────────────────

class _TabAktif extends StatelessWidget {
  final PengelolaController controller;
  const _TabAktif({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listPengelola.isEmpty) {
        return EmptyState(
          icon: Icons.people_outline_rounded,
          message: 'Belum ada pengelola aktif.',
          actionLabel: 'Tambah Pengelola',
          onAction: () {
            controller.resetForm();
            Get.toNamed(AppRoutes.formPengelola);
          },
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchAll,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.listPengelola.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final pengelola = controller.listPengelola[i];
            return _PengelolaCard(
              pengelola: pengelola,
              controller: controller,
              onHapus: () => _confirmHapus(context, pengelola, controller),
              onAturBankSampah: () =>
                  _showAturBankSampahSheet(context, pengelola, controller),
            );
          },
        ),
      );
    });
  }
}

// ── Tab Menunggu Verifikasi ────────────────────────────────────────────────────

class _TabPending extends StatelessWidget {
  final PengelolaController controller;
  const _TabPending({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listPending.isEmpty) {
        return const EmptyState(
          icon: Icons.hourglass_empty_rounded,
          message: 'Tidak ada pendaftaran yang menunggu verifikasi.',
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchAll,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: controller.listPending.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final pengelola = controller.listPending[i];
            return _PendingCard(
              pengelola: pengelola,
              listBankSampah: controller.listBankSampah,
              controller: controller,
              onApprove: () =>
                  _showApproveSheet(context, pengelola, controller),
              onTolak: () => _confirmTolak(context, pengelola, controller),
            );
          },
        ),
      );
    });
  }
}

// ── Card Pengelola Aktif ───────────────────────────────────────────────────────

class _PengelolaCard extends StatelessWidget {
  final ProfileModel pengelola;
  final VoidCallback onHapus;
  final VoidCallback onAturBankSampah;
  final PengelolaController controller;

  const _PengelolaCard({
    required this.pengelola,
    required this.onHapus,
    required this.onAturBankSampah,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _showInfoSheet(context, pengelola, controller),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryContainer.withOpacity(0.2),
            child: Text(
              pengelola.namaLengkap.isNotEmpty
                  ? pengelola.namaLengkap[0].toUpperCase()
                  : '?',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pengelola.namaLengkap, style: AppTextStyles.titleMd),
                if (pengelola.noHp != null && pengelola.noHp!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(pengelola.noHp!, style: AppTextStyles.bodyMd),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'Bergabung ${FormatHelper.date(pengelola.createdAt)}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
            onPressed: onHapus,
            tooltip: 'Hapus Pengelola',
          ),
        ],
      ),
    );
  }
}

// ── Card Pengelola Pending ─────────────────────────────────────────────────────

class _PendingCard extends StatelessWidget {
  final ProfileModel pengelola;
  final List<BankSampahModel> listBankSampah;
  final PengelolaController controller;
  final VoidCallback onApprove;
  final VoidCallback onTolak;

  const _PendingCard({
    required this.pengelola,
    required this.listBankSampah,
    required this.controller,
    required this.onApprove,
    required this.onTolak,
  });

  @override
  Widget build(BuildContext context) {
    // Nama bank sampah yang dipilih saat registrasi
    final namaPilihan = pengelola.bankSampahPilihan.isEmpty
        ? null
        : listBankSampah
              .where((b) => pengelola.bankSampahPilihan.contains(b.id))
              .map((b) => b.namaLengkap)
              .join(', ');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info pengelola
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.warningContainer,
                child: Text(
                  pengelola.namaLengkap.isNotEmpty
                      ? pengelola.namaLengkap[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.titleMd.copyWith(
                    color: AppColors.onBackground,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pengelola.namaLengkap,
                            style: AppTextStyles.titleMd,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: Text(
                            'Menunggu',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (pengelola.noHp != null &&
                        pengelola.noHp!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(pengelola.noHp!, style: AppTextStyles.bodyMd),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'Daftar ${FormatHelper.date(pengelola.createdAt)}',
                      style: AppTextStyles.labelSm,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Pilihan bank sampah saat registrasi
          if (namaPilihan != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 14,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pilihan: $namaPilihan',
                      style: AppTextStyles.labelSm,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Tombol aksi
          Obx(() {
            final isProcessing = controller.isApprovingId.value == pengelola.id;
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onTolak,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: isProcessing ? null : onApprove,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Setujui & Atur'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Bottom Sheet: Approve + Pilih Bank Sampah ─────────────────────────────────

Future<void> _showApproveSheet(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  // Pre-select pilihan bank sampah dari registrasi
  final selected = pengelola.bankSampahPilihan.obs;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusXl),
      ),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text('Setujui Pendaftaran', style: AppTextStyles.titleLg),
            Text(pengelola.namaLengkap, style: AppTextStyles.bodyMd),
            const SizedBox(height: 4),
            Text(
              'Pilih bank sampah yang akan dikelola:',
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  controller: scrollCtrl,
                  itemCount: controller.listBankSampah.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final bank = controller.listBankSampah[i];
                    return Obx(
                      () => CheckboxListTile(
                        title: Text(
                          bank.namaLengkap,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onBackground,
                          ),
                        ),
                        subtitle: bank.alamat != null
                            ? Text(bank.alamat!, style: AppTextStyles.labelSm)
                            : null,
                        value: selected.contains(bank.id),
                        onChanged: (v) {
                          if (v == true) {
                            selected.add(bank.id);
                          } else {
                            selected.remove(bank.id);
                          }
                        },
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => AppButton(
                label: 'Setujui Pengelola',
                icon: Icons.check_circle_outline_rounded,
                isLoading: controller.isApprovingId.value == pengelola.id,
                onPressed: () async {
                  await controller.approvePengelola(
                    pengelola.id,
                    selected.toList(),
                  );
                  // isApprovingId kosong artinya proses selesai (sukses/gagal)
                  // cek sukses via listPending sudah tidak mengandung id ini
                  if (!controller.listPending.any((p) => p.id == pengelola.id)) {
                    Navigator.of(ctx).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Bottom Sheet: Atur Bank Sampah (pengelola aktif) ──────────────────────────

Future<void> _showAturBankSampahSheet(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final existing = await controller.getBankSampahPengelola(pengelola.id);
  final selected = existing.obs;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusXl),
      ),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text('Atur Bank Sampah', style: AppTextStyles.titleLg),
            Text(pengelola.namaLengkap, style: AppTextStyles.bodyMd),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  controller: scrollCtrl,
                  itemCount: controller.listBankSampah.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final bank = controller.listBankSampah[i];
                    return Obx(
                      () => CheckboxListTile(
                        title: Text(
                          bank.namaLengkap,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onBackground,
                          ),
                        ),
                        subtitle: bank.alamat != null
                            ? Text(bank.alamat!, style: AppTextStyles.labelSm)
                            : null,
                        value: selected.contains(bank.id),
                        onChanged: (v) {
                          if (v == true) {
                            selected.add(bank.id);
                          } else {
                            selected.remove(bank.id);
                          }
                        },
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => AppButton(
                label: 'Simpan Relasi',
                isLoading: controller.isSaving.value,
                onPressed: () async {
                  await controller.updateRelasiPengelola(
                    pengelola.id,
                    selected.toList(),
                  );
                  if (!controller.isSaving.value) {
                    Navigator.of(ctx).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Info Sheet Pengelola ───────────────────────────────────────────────────────

Future<void> _showInfoSheet(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  // fetch bank sampah yang dikelola
  final ids = await controller.getBankSampahPengelola(pengelola.id);
  final banks = controller.listBankSampah
      .where((b) => ids.contains(b.id))
      .toList();

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryContainer.withOpacity(0.2),
                  child: Text(
                    pengelola.namaLengkap.isNotEmpty
                        ? pengelola.namaLengkap[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pengelola.namaLengkap, style: AppTextStyles.titleMd),
                      if (pengelola.noHp != null && pengelola.noHp!.isNotEmpty)
                        Text(
                          pengelola.noHp!,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Bank Sampah yang Dikelola',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (banks.isEmpty)
              Text(
                'Belum ada bank sampah yang dikelola.',
                style: AppTextStyles.bodyMd,
              )
            else
              ...banks.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.nama, style: AppTextStyles.titleMd),

                            Text(
                              [
                                if (b.rt?.isNotEmpty ?? false) 'RT ${b.rt}',
                                if (b.rw?.isNotEmpty ?? false) 'RW ${b.rw}',
                              ].join(' / '),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

// ── Dialog konfirmasi ──────────────────────────────────────────────────────────

Future<void> _confirmHapus(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final ok = await ConfirmDialog.show(
    title: 'Hapus Pengelola',
    message:
        'Yakin ingin menghapus "${pengelola.namaLengkap}"? Akun dan semua relasinya akan dihapus.',
    confirmLabel: 'Hapus',
    isDanger: true,
  );
  if (ok) controller.hapusPengelola(pengelola.id);
}

Future<void> _confirmTolak(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final ok = await ConfirmDialog.show(
    title: 'Tolak Pendaftaran',
    message:
        'Yakin ingin menolak pendaftaran "${pengelola.namaLengkap}"? Akun akan dihapus permanen.',
    confirmLabel: 'Tolak',
    isDanger: true,
  );
  if (ok) controller.tolakPengelola(pengelola.id);
}