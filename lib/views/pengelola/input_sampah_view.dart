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
        title: Text(
          controller.isEditMode ? 'Edit Data Sampah' : 'Input Data Sampah',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Jenis Sampah ──────────────────────────────
            _SectionCard(
              title: 'Jenis Sampah',
              child: Column(
                children: [
                  // 1. Kategori (selalu tampil, wajib)
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

                  // 2. Sub Kategori — hanya muncul jika kategori dipilih
                  //    DAN listSubKategori tidak kosong
                  Obx(() {
                    if (controller.selectedKategoriId.value.isEmpty ||
                        controller.listSubKategori.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(children: [
                      const SizedBox(height: 16),
                      _DropdownField<String>(
                        label: 'Sub Kategori *',
                        hint: 'Pilih sub kategori',
                        value: controller.selectedSubKategoriId.value.isEmpty
                            ? null
                            : controller.selectedSubKategoriId.value,
                        items: controller.listSubKategori
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.nama),
                                ))
                            .toList(),
                        validator: (v) =>
                            AppValidator.required(v, fieldName: 'Sub Kategori'),
                        onChanged: controller.onSubKategoriChanged,
                      ),
                    ]);
                  }),

                  // 3. Tipe — hanya muncul jika sub kategori dipilih
                  //    DAN listTipe tidak kosong
                  Obx(() {
                    if (controller.selectedSubKategoriId.value.isEmpty ||
                        controller.listTipe.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(children: [
                      const SizedBox(height: 16),
                      _DropdownField<String>(
                        label: 'Tipe *',
                        hint: 'Pilih tipe material',
                        value: controller.selectedTipeId.value.isEmpty
                            ? null
                            : controller.selectedTipeId.value,
                        items: controller.listTipe
                            .map((t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.nama),
                                ))
                            .toList(),
                        validator: (v) =>
                            AppValidator.required(v, fieldName: 'Tipe'),
                        onChanged: controller.onTipeChanged,
                      ),
                    ]);
                  }),

                  // 4. Jenis Sampah — hanya muncul jika listJenisSampah tidak kosong
                  //    dan semua prasyarat terpenuhi
                  Obx(() {
                    if (controller.listJenisSampah.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    // Cek prasyarat: jika ada tipe tapi belum dipilih, jangan tampil
                    if (controller.listTipe.isNotEmpty &&
                        controller.selectedTipeId.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(children: [
                      const SizedBox(height: 16),
                      _DropdownField<String>(
                        label: 'Jenis Sampah *',
                        hint: 'Pilih jenis sampah',
                        value: controller.selectedJenisId.value.isEmpty
                            ? null
                            : controller.selectedJenisId.value,
                        items: controller.listJenisSampah
                            .map((j) => DropdownMenuItem(
                                  value: j.id,
                                  child: Text(j.nama),
                                ))
                            .toList(),
                        validator: (v) => AppValidator.required(v,
                            fieldName: 'Jenis Sampah'),
                        onChanged: controller.onJenisChanged,
                      ),
                    ]);
                  }),
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
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.singkatan),
                                ))
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

            // ── Harga Manual (WIP) ────────────────────────
            _HargaManualSection(),
            const SizedBox(height: 16),

            // ── Tanggal Pengelolaan ───────────────────────
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

            // ── Harga snapshot otomatis ───────────────────
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
                        const Icon(Icons.sell_outlined,
                            color: AppColors.outline, size: 20),
                        const SizedBox(width: 8),
                        Text('Harga terdaftar:', style: AppTextStyles.bodyMd),
                        const Spacer(),
                        Text(
                          FormatHelper.currency(
                            controller.hargaSnapshot.value!.hargaPerSatuan,
                          ),
                          style: AppTextStyles.titleMd
                              .copyWith(color: AppColors.primary),
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
                          Text('Estimasi total:',
                              style: AppTextStyles.bodyMd),
                          Text(
                            FormatHelper.currency(
                              (double.tryParse(controller.jumlahController.text
                                          .replaceAll(',', '.')) ??
                                      0) *
                                  controller
                                      .hargaSnapshot.value!.hargaPerSatuan,
                            ),
                            style: AppTextStyles.titleMd
                                .copyWith(color: AppColors.secondary),
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

            // ── Tombol Simpan ─────────────────────────────
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────
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

// ── Harga Manual Section (WIP / disabled) ─────────────────
class _HargaManualSection extends StatelessWidget {
  const _HargaManualSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                child: Row(
                  children: [
                    Text('Harga Manual', style: AppTextStyles.titleMd),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.construction_rounded,
                              size: 11, color: Color(0xFFE65100)),
                          SizedBox(width: 4),
                          Text(
                            'Dalam Pengembangan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFFFCC02)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: Color(0xFFF57F17)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Fitur input harga manual masih dalam tahap pengembangan dan belum dapat digunakan. Fitur ini akan segera tersedia pada versi berikutnya.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5D4037),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    IgnorePointer(
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Harga per Satuan (Rp)',
                          hintText: 'Contoh: 5000',
                          prefixIcon: const Icon(Icons.sell_outlined,
                              color: AppColors.outline),
                          filled: true,
                          fillColor: AppColors.surfaceLow,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: const BorderSide(
                                color: AppColors.outlineVariant),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: const BorderSide(
                                color: AppColors.outlineVariant),
                          ),
                        ),
                        style: AppTextStyles.bodyLg
                            .copyWith(color: AppColors.outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border:
                            Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimasi Total:',
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.outline)),
                          Text('Rp —',
                              style: AppTextStyles.titleMd
                                  .copyWith(color: AppColors.outline)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: AbsorbPointer(
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dropdown Field ────────────────────────────────────────
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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
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