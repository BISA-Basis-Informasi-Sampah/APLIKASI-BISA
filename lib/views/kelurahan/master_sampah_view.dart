import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/master_sampah_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/satuan_model.dart';

class MasterSampahView extends GetView<MasterSampahController> {
  const MasterSampahView({super.key});

  static const _tabs = ['Kategori', 'Sub Kategori', 'Jenis', 'Satuan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Master Data Sampah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _TabChip(
                      label: _tabs[i],
                      isActive: controller.activeTab.value == i,
                      onTap: () => controller.activeTab.value = i,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        return switch (controller.activeTab.value) {
          0 => _KategoriTab(controller: controller),
          1 => _SubKategoriTab(controller: controller),
          2 => _JenisTab(controller: controller),
          3 => _SatuanTab(controller: controller),
          _ => const SizedBox.shrink(),
        };
      }),
    );
  }
}

// ── Tab Chip ──────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Generic Add Form Sheet ─────────────────────────────────────────────────────

void _showAddSheet(
  BuildContext context, {
  required String title,
  required Widget formContent,
  required VoidCallback onSimpan,
  required MasterSampahController controller,
}) {
  Get.bottomSheet(
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusXl),
      ),
    ),
    Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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
            Text(title, style: AppTextStyles.titleLg),
            const SizedBox(height: 16),
            formContent,
            const SizedBox(height: 20),
            Obx(
              () => AppButton(
                label: 'Simpan',
                isLoading: controller.isSaving.value,
                onPressed: onSimpan,
              ),
            ),
          ],
        ),
      ),
    ),
  ).then((_) => controller.resetForm());
}

// ── Tab Kategori ──────────────────────────────────────────────────────────────

class _KategoriTab extends StatelessWidget {
  final MasterSampahController controller;
  const _KategoriTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Kategori',
          controller: controller,
          onSimpan: controller.simpanKategori,
          formContent: Column(
            children: [
              AppTextField(
                controller: controller.namaController,
                label: 'Nama Kategori',
                prefixIcon: Icons.label_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.deskripsiController,
                label: 'Deskripsi (opsional)',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kategori'),
      ),
      body: Obx(() {
        if (controller.listKategori.isEmpty) {
          return const EmptyState(
            icon: Icons.category_outlined,
            message: 'Belum ada kategori sampah.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.listKategori.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = controller.listKategori[i];
              return _MasterItemCard(
                nama: item.nama,
                subtitle: item.deskripsi,
                onDelete: () => _confirmHapus(
                  context,
                  nama: item.nama,
                  onConfirm: () => controller.hapusKategori(item.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Tab Sub Kategori ──────────────────────────────────────────────────────────

class _SubKategoriTab extends StatelessWidget {
  final MasterSampahController controller;
  const _SubKategoriTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Sub Kategori',
          controller: controller,
          onSimpan: controller.simpanSubKategori,
          formContent: Column(
            children: [
              Obx(
                () => DropdownButtonFormField<KategoriModel>(
                  value: controller.selectedKategoriForm.value,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: AppColors.outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  items: controller.listKategoriDropdown
                      .map(
                        (k) => DropdownMenuItem(value: k, child: Text(k.nama)),
                      )
                      .toList(),
                  onChanged: (v) => controller.selectedKategoriForm.value = v,
                  validator: (v) => v == null ? 'Pilih kategori' : null,
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.namaController,
                label: 'Nama Sub Kategori',
                prefixIcon: Icons.label_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.deskripsiController,
                label: 'Deskripsi (opsional)',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Sub Kategori'),
      ),
      body: Obx(() {
        if (controller.listSubKategori.isEmpty) {
          return const EmptyState(
            icon: Icons.layers_outlined,
            message: 'Belum ada sub kategori.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.listSubKategori.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = controller.listSubKategori[i];
              return _MasterItemCard(
                nama: item.nama,
                subtitle: item.kategori != null
                    ? 'Kategori: ${item.kategori!.nama}'
                    : null,
                onDelete: () => _confirmHapus(
                  context,
                  nama: item.nama,
                  onConfirm: () => controller.hapusSubKategori(item.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Tab Jenis ─────────────────────────────────────────────────────────────────

class _JenisTab extends StatelessWidget {
  final MasterSampahController controller;
  const _JenisTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Jenis Sampah',
          controller: controller,
          onSimpan: controller.simpanJenis,
          formContent: Column(
            children: [
              Obx(
                () => DropdownButtonFormField<KategoriModel>(
                  value: controller.selectedKategoriForm.value,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: AppColors.outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  items: controller.listKategoriDropdown
                      .map(
                        (k) => DropdownMenuItem(value: k, child: Text(k.nama)),
                      )
                      .toList(),
                  onChanged: (v) {
                    controller.selectedKategoriForm.value = v;
                    controller.selectedSubKategoriForm.value = null;
                  },
                  validator: (v) => v == null ? 'Pilih kategori' : null,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<SubKategoriModel>(
                  value: controller.selectedSubKategoriForm.value,
                  decoration: InputDecoration(
                    labelText: 'Sub Kategori',
                    prefixIcon: const Icon(
                      Icons.layers_outlined,
                      size: 20,
                      color: AppColors.outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  items: controller.listSubKategoriDropdown
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.nama)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      controller.selectedSubKategoriForm.value = v,
                  validator: (v) => v == null ? 'Pilih sub kategori' : null,
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.namaController,
                label: 'Nama Jenis',
                prefixIcon: Icons.label_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<SatuanModel>(
                  value: controller.selectedSatuanForm.value,
                  decoration: InputDecoration(
                    labelText: 'Satuan Default (opsional)',
                    prefixIcon: const Icon(
                      Icons.straighten_rounded,
                      size: 20,
                      color: AppColors.outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  items: controller.listSatuan
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text('${s.nama} (${s.singkatan})'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => controller.selectedSatuanForm.value = v,
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.deskripsiController,
                label: 'Deskripsi (opsional)',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Jenis'),
      ),
      body: Obx(() {
        if (controller.listJenis.isEmpty) {
          return const EmptyState(
            icon: Icons.eco_outlined,
            message: 'Belum ada jenis sampah.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.listJenis.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = controller.listJenis[i];
              final breadcrumb = [
                if (item.subKategori?.kategori != null)
                  item.subKategori!.kategori!.nama,
                if (item.subKategori != null) item.subKategori!.nama,
              ].join(' › ');
              return _MasterItemCard(
                nama: item.nama,
                subtitle: breadcrumb.isNotEmpty ? breadcrumb : null,
                trailing: item.satuanDefault != null
                    ? _SatuanBadge(satuan: item.satuanDefault!.singkatan)
                    : null,
                onDelete: () => _confirmHapus(
                  context,
                  nama: item.nama,
                  onConfirm: () => controller.hapusJenis(item.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Tab Satuan ────────────────────────────────────────────────────────────────

class _SatuanTab extends StatelessWidget {
  final MasterSampahController controller;
  const _SatuanTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Satuan',
          controller: controller,
          onSimpan: controller.simpanSatuan,
          formContent: Column(
            children: [
              AppTextField(
                controller: controller.namaController,
                label: 'Nama Satuan',
                hint: 'contoh: Kilogram',
                prefixIcon: Icons.straighten_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.singkatanController,
                label: 'Singkatan',
                hint: 'contoh: kg',
                prefixIcon: Icons.short_text_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Singkatan wajib diisi' : null,
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Satuan'),
      ),
      body: Obx(() {
        if (controller.listSatuan.isEmpty) {
          return const EmptyState(
            icon: Icons.straighten_outlined,
            message: 'Belum ada satuan.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.listSatuan.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = controller.listSatuan[i];
              return _MasterItemCard(
                nama: item.nama,
                trailing: _SatuanBadge(satuan: item.singkatan),
                onDelete: () => _confirmHapus(
                  context,
                  nama: item.nama,
                  onConfirm: () => controller.hapusSatuan(item.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _MasterItemCard extends StatelessWidget {
  final String nama;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onDelete;

  const _MasterItemCard({
    required this.nama,
    this.subtitle,
    this.trailing,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: AppTextStyles.titleMd),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: onDelete,
            tooltip: 'Hapus',
          ),
        ],
      ),
    );
  }
}

class _SatuanBadge extends StatelessWidget {
  final String satuan;
  const _SatuanBadge({required this.satuan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        satuan,
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

Future<void> _confirmHapus(
  BuildContext context, {
  required String nama,
  required VoidCallback onConfirm,
}) async {
  final ok = await ConfirmDialog.show(
    title: 'Hapus Data',
    message:
        'Yakin ingin menghapus "$nama"? Data yang terhubung mungkin ikut terpengaruh.',
    confirmLabel: 'Hapus',
    isDanger: true,
  );
  if (ok) onConfirm();
}
