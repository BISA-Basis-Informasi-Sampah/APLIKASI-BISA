import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/pengelola/harga_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/harga_sampah_model.dart';

class HargaView extends GetView<HargaController> {
  const HargaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Harga Sampah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Tombol + disabled (WIP)
          IgnorePointer(
            child: Opacity(
              opacity: 0.35,
              child: IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: null,
                tooltip: 'Dalam Pengembangan',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner disclaimer WIP
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFCC02)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.construction_rounded,
                    size: 20, color: Color(0xFFF57F17)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fitur Dalam Pengembangan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Halaman Daftar Harga Sampah masih dalam tahap pengembangan dan belum dapat digunakan. Fitur ini akan segera tersedia pada versi berikutnya.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5D4037),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Konten WIP (visual only, semua disabled)
          Expanded(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.45,
                child: Obx(() {
                  if (controller.isLoading.value) return const LoadingWidget();

                  if (controller.listHarga.isEmpty) {
                    return EmptyState(
                      icon: Icons.sell_outlined,
                      message:
                          'Belum ada data harga.\nTambahkan harga untuk tiap jenis sampah.',
                      actionLabel: 'Tambah Harga',
                      onAction: () {},
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchHarga,
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Info banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.infoContainer,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: AppColors.info, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Harga akan otomatis tersimpan saat input data sampah.',
                                  style: AppTextStyles.bodyMd
                                      .copyWith(color: AppColors.info),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...controller.hargaPerKategori.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull),
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.onPrimaryContainer),
                                  ),
                                ),
                              ),
                              ...entry.value.map((harga) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _HargaCard(
                                      harga: harga,
                                      onEdit: () {},
                                      onDelete: () {},
                                    ),
                                  )),
                              const SizedBox(height: 8),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: IgnorePointer(
        child: Opacity(
          opacity: 0.35,
          child: FloatingActionButton(
            onPressed: null,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ),
    );
  }

  void _showFormSheet(BuildContext context, HargaSampahModel? existing) {
    if (existing != null) controller.initEdit(existing);
    else controller.resetForm();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) => _HargaFormSheet(controller: controller),
    );
  }
}

class _HargaCard extends StatelessWidget {
  final HargaSampahModel harga;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HargaCard({
    required this.harga,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(Icons.sell_outlined,
                color: AppColors.onSecondaryContainer, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(harga.namaItem,
                    style: AppTextStyles.titleMd),
                Text(harga.breadcrumb,
                    style: AppTextStyles.bodyMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FormatHelper.currency(harga.hargaPerSatuan),
                style: AppTextStyles.titleMd
                    .copyWith(color: AppColors.primary),
              ),
              Text(
                '/ ${harga.satuan?.singkatan ?? '-'}',
                style: AppTextStyles.labelSm,
              ),
            ],
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.outline, size: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: AppColors.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HargaFormSheet extends StatelessWidget {
  final HargaController controller;

  const _HargaFormSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.isEditMode ? 'Edit Harga' : 'Tambah Harga',
                  style: AppTextStyles.titleLg,
                )),
            const SizedBox(height: 20),

            // Kategori
            Obx(() => _DropdownField<String>(
                  label: 'Kategori *',
                  hint: 'Pilih kategori',
                  value: controller.selectedKategoriId.value.isEmpty
                      ? null
                      : controller.selectedKategoriId.value,
                  items: controller.listKategori
                      .map((k) => DropdownMenuItem(
                            value: k.id,
                            child: Text(k.nama),
                          ))
                      .toList(),
                  validator: (v) =>
                      AppValidator.required(v, fieldName: 'Kategori'),
                  onChanged: controller.onKategoriChanged,
                )),
            const SizedBox(height: 12),

            // Sub kategori (opsional)
            Obx(() => _DropdownField<String>(
                  label: 'Sub Kategori (opsional)',
                  hint: controller.listSubKategori.isEmpty
                      ? 'Pilih kategori dahulu'
                      : 'Pilih sub kategori',
                  value: controller.selectedSubKategoriId.value.isEmpty
                      ? null
                      : controller.selectedSubKategoriId.value,
                  items: controller.listSubKategori
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.nama),
                          ))
                      .toList(),
                  enabled: controller.listSubKategori.isNotEmpty,
                  onChanged: controller.onSubKategoriChanged,
                )),
            const SizedBox(height: 12),

            // Jenis (opsional)
            Obx(() => _DropdownField<String>(
                  label: 'Jenis Sampah (opsional)',
                  hint: controller.listJenisSampah.isEmpty
                      ? 'Pilih sub kategori dahulu'
                      : 'Pilih jenis sampah',
                  value: controller.selectedJenisId.value.isEmpty
                      ? null
                      : controller.selectedJenisId.value,
                  items: controller.listJenisSampah
                      .map((j) => DropdownMenuItem(
                            value: j.id,
                            child: Text(j.nama),
                          ))
                      .toList(),
                  enabled: controller.listJenisSampah.isNotEmpty,
                  onChanged: (v) =>
                      controller.selectedJenisId.value = v ?? '',
                )),
            const SizedBox(height: 12),

            // Harga & Satuan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: controller.hargaController,
                    label: 'Harga *',
                    hint: 'Contoh: 2500',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: AppValidator.harga,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _DropdownField<String>(
                        label: 'Satuan *',
                        hint: 'Satuan',
                        value: controller.selectedSatuanId.value.isEmpty
                            ? null
                            : controller.selectedSatuanId.value,
                        items: controller.listSatuan
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.singkatan),
                                ))
                            .toList(),
                        validator: (v) =>
                            AppValidator.required(v, fieldName: 'Satuan'),
                        onChanged: (v) =>
                            controller.selectedSatuanId.value = v ?? '',
                      )),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Batal',
                    outlined: true,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => AppButton(
                        label: controller.isEditMode ? 'Simpan' : 'Tambah',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.simpan,
                        icon: Icons.check_rounded,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      style: AppTextStyles.bodyLg,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled ? AppColors.surfaceLowest : AppColors.surfaceLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      dropdownColor: AppColors.surfaceLowest,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.outline),
    );
  }
}