import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/pengelola/input_sampah_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class InputSampahView extends GetView<InputSampahController> {
  const InputSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLowest,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Obx(
          () => Text(
            controller.isEditMode ? 'Edit Data Sampah' : 'Input Data Sampah',
          ),
        ),
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
            // ── Kategori ──────────────────────────────────
            _SectionCard(
              title: 'Jenis Sampah',
              child: Column(
                children: [
                  // Kategori (wajib)
                  Obx(
                    () => _DropdownField<String>(
                      label: 'Kategori *',
                      hint: 'Pilih kategori',
                      value: controller.selectedKategoriId.value.isEmpty
                          ? null
                          : controller.selectedKategoriId.value,
                      items: controller.listKategori
                          .map(
                            (k) => DropdownMenuItem(
                              value: k.id,
                              child: Text(k.nama),
                            ),
                          )
                          .toList(),
                      validator: (v) =>
                          AppValidator.required(v, fieldName: 'Kategori'),
                      onChanged: controller.onKategoriChanged,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sub kategori (opsional)
                  Obx(
                    () => _DropdownField<String>(
                      label: 'Sub Kategori (opsional)',
                      hint: controller.listSubKategori.isEmpty
                          ? 'Pilih kategori dahulu'
                          : 'Pilih sub kategori',
                      value: controller.selectedSubKategoriId.value.isEmpty
                          ? null
                          : controller.selectedSubKategoriId.value,
                      items: controller.listSubKategori
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.nama),
                            ),
                          )
                          .toList(),
                      enabled: controller.listSubKategori.isNotEmpty,
                      onChanged: controller.onSubKategoriChanged,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Jenis sampah (opsional)
                  Obx(
                    () => _DropdownField<String>(
                      label: 'Jenis Sampah (opsional)',
                      hint: controller.listJenisSampah.isEmpty
                          ? 'Pilih sub kategori dahulu'
                          : 'Pilih jenis sampah',
                      value: controller.selectedJenisId.value.isEmpty
                          ? null
                          : controller.selectedJenisId.value,
                      items: controller.listJenisSampah
                          .map(
                            (j) => DropdownMenuItem(
                              value: j.id,
                              child: Text(j.nama),
                            ),
                          )
                          .toList(),
                      enabled: controller.listJenisSampah.isNotEmpty,
                      onChanged: controller.onJenisChanged,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Jumlah & Satuan ───────────────────────────
            _SectionCard(
              title: 'Jumlah',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: controller.jumlahController,
                      label: 'Jumlah *',
                      hint: 'Contoh: 12.5',
                      prefixIcon: Icons.scale_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: AppValidator.jumlah,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _DropdownField<String>(
                        label: 'Satuan *',
                        hint: 'Satuan',
                        value: controller.selectedSatuanId.value.isEmpty
                            ? null
                            : controller.selectedSatuanId.value,
                        items: controller.listSatuan
                            .map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.singkatan),
                              ),
                            )
                            .toList(),
                        validator: (v) =>
                            AppValidator.required(v, fieldName: 'Satuan'),
                        onChanged: (v) =>
                            controller.selectedSatuanId.value = v ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tanggal ───────────────────────────────────
            _SectionCard(
              title: 'Tanggal Pengelolaan',
              child: Obx(
                () => AppTextField(
                  controller: controller.tanggalController,
                  label: 'Tanggal *',
                  hint: 'Pilih tanggal',
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => controller.pickTanggal(context),
                  validator: (_) =>
                      AppValidator.tanggal(controller.selectedTanggal.value),
                  suffixIcon: controller.selectedTanggal.value != null
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.outline,
                            size: 18,
                          ),
                          onPressed: controller.clearTanggal,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Harga (snapshot otomatis) ─────────────────
            Obx(() {
              if (controller.hargaSnapshot.value == null) {
                return const SizedBox.shrink();
              }
              return _SectionCard(
                title: 'Harga',
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          color: AppColors.outline,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text('Harga terdaftar:', style: AppTextStyles.bodyMd),
                        const Spacer(),
                        Text(
                          FormatHelper.currency(
                            controller.hargaSnapshot.value!.hargaPerSatuan,
                          ),
                          style: AppTextStyles.titleMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          ' / ${controller.hargaSnapshot.value!.satuan?.singkatan ?? ''}',
                          style: AppTextStyles.bodyMd,
                        ),
                      ],
                    ),
                    if (controller.jumlahController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimasi total:', style: AppTextStyles.bodyMd),
                          Text(
                            FormatHelper.currency(
                              (double.tryParse(
                                        controller.jumlahController.text
                                            .replaceAll(',', '.'),
                                      ) ??
                                      0) *
                                  controller
                                      .hargaSnapshot
                                      .value!
                                      .hargaPerSatuan,
                            ),
                            style: AppTextStyles.titleMd.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // ── Catatan ───────────────────────────────────
            _SectionCard(
              title: 'Catatan',
              child: AppTextField(
                controller: controller.catatanController,
                label: 'Catatan (opsional)',
                hint: 'Tambahkan catatan jika perlu',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),

            // ── Tombol simpan ─────────────────────────────
            Obx(
              () => AppButton(
                label: controller.isEditMode
                    ? 'Simpan Perubahan'
                    : 'Simpan Data',
                isLoading: controller.isLoading.value,
                onPressed: controller.simpan,
                icon: Icons.save_rounded,
              ),
            ),
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

// ── Reusable section card ──────────────────────────────────
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
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ── Reusable dropdown field ────────────────────────────────
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.outline,
      ),
    );
  }
}