import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/laporan_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

class LaporanView extends GetView<LaporanController> {
  const LaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generator Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Laporan ───────────────────────────
            Text('Konfigurasi Laporan', style: AppTextStyles.titleMd),
            const SizedBox(height: 12),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jenis Laporan
                  Text(
                    'Jenis Laporan',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Column(
                      children: controller.jenisLaporanOptions.entries
                          .map(
                            (entry) => RadioListTile<JenisLaporan>(
                              title: Text(
                                entry.value,
                                style: AppTextStyles.bodyMd,
                              ),
                              value: entry.key,
                              groupValue: controller.selectedJenisLaporan.value,
                              onChanged: (v) {
                                if (v != null)
                                  controller.selectedJenisLaporan.value = v;
                              },
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Bank Sampah
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank Sampah',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<BankSampahModel?>(
                      value: controller.selectedBankSampah.value,
                      decoration: InputDecoration(
                        hintText: 'Semua bank sampah',
                        prefixIcon: const Icon(
                          Icons.store_outlined,
                          size: 20,
                          color: AppColors.outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<BankSampahModel?>(
                          value: null,
                          child: Text('Semua Bank Sampah'),
                        ),
                        ...controller.listBankSampah.map(
                          (b) => DropdownMenuItem<BankSampahModel?>(
                            value: b,
                            child: Text(b.namaLengkap),
                          ),
                        ),
                      ],
                      onChanged: (v) => controller.selectedBankSampah.value = v,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Periode
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periode',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _DatePickerField(
                            label: 'Tanggal Mulai',
                            value: controller.selectedTanggalMulai.value,
                            onPick: (d) =>
                                controller.selectedTanggalMulai.value = d,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _DatePickerField(
                            label: 'Tanggal Akhir',
                            value: controller.selectedTanggalAkhir.value,
                            onPick: (d) =>
                                controller.selectedTanggalAkhir.value = d,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tombol Aksi ──────────────────────────────
            Obx(
              () => AppButton(
                label: 'Tampilkan Preview',
                isLoading: controller.isGenerating.value,
                onPressed: controller.previewLaporan,
                icon: Icons.preview_rounded,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => AppButton(
                      label: 'Export Excel',
                      outlined: true,
                      isLoading: controller.isGenerating.value,
                      onPressed: controller.exportExcel,
                      icon: Icons.table_chart_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => AppButton(
                      label: 'Export CSV',
                      outlined: true,
                      isLoading: controller.isGenerating.value,
                      onPressed: controller.exportCsv,
                      icon: Icons.download_rounded,
                    ),
                  ),
                ),
              ],
            ),

            // ── Preview Data ─────────────────────────────
            Obx(() {
              if (!controller.hasPreview.value) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Preview (${controller.previewData.length} data)',
                  ),
                  const SizedBox(height: 10),

                  if (controller.previewData.isEmpty)
                    const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'Tidak ada data pada periode yang dipilih.',
                    )
                  else
                    ...controller.previewData.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaItem,
                                      style: AppTextStyles.titleMd,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.bankSampah?.nama ?? '-'}  ·  ${FormatHelper.date(item.tanggalPengelolaan)}',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '${FormatHelper.number(item.jumlah)} ${item.satuan?.singkatan ?? ''}',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.totalHarga != null)
                                Text(
                                  FormatHelper.currency(item.totalHarga),
                                  style: AppTextStyles.titleMd.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Summary total
                  if (controller.previewData.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AppCard(
                      color: AppColors.primaryContainer.withOpacity(0.1),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Nilai',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                FormatHelper.currency(
                                  controller.previewData.fold<double>(
                                    0,
                                    (sum, e) => sum + (e.totalHarga ?? 0),
                                  ),
                                ),
                                style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Transaksi',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${controller.previewData.length}x',
                                style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Date Picker Field ─────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.outline,
            ),
            const SizedBox(width: 8),
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
                  Text(
                    value != null ? FormatHelper.date(value) : 'Pilih tanggal',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: value != null
                          ? AppColors.onSurface
                          : AppColors.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
