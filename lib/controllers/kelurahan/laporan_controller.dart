import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/utils/format_helper.dart';
import '../../models/bank_sampah_model.dart';
import '../../models/pengelolaan_sampah_model.dart';

enum JenisLaporan {
  ringkasanMonitoring,
  rekapTransaksi,
  statistikKategori,
  aktivitasBankSampah,
}

class LaporanController extends GetxController {
  final listBankSampah = <BankSampahModel>[].obs;
  final selectedBankSampah = Rx<BankSampahModel?>(null);
  final selectedJenisLaporan = Rx<JenisLaporan>(JenisLaporan.rekapTransaksi);
  final selectedTanggalMulai = Rx<DateTime?>(null);
  final selectedTanggalAkhir = Rx<DateTime?>(null);

  final isLoading = false.obs;
  final isGenerating = false.obs;

  // Data hasil query untuk preview
  final previewData = <PengelolaanSampahModel>[].obs;
  final hasPreview = false.obs;

  final jenisLaporanOptions = {
    JenisLaporan.ringkasanMonitoring: 'Ringkasan Monitoring',
    JenisLaporan.rekapTransaksi: 'Rekap Transaksi Sampah',
    JenisLaporan.statistikKategori: 'Statistik Kategori Sampah',
    JenisLaporan.aktivitasBankSampah: 'Aktivitas Bank Sampah',
  };

  @override
  void onInit() {
    super.onInit();
    _fetchBankSampah();
    // Default periode: bulan ini
    final now = DateTime.now();
    selectedTanggalMulai.value = DateTime(now.year, now.month, 1);
    selectedTanggalAkhir.value = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _fetchBankSampah() async {
    isLoading.value = true;
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableBankSampah)
          .select()
          .order('nama');
      listBankSampah.value = (data as List)
          .map((e) => BankSampahModel.fromJson(e))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  bool get isValid =>
      selectedTanggalMulai.value != null && selectedTanggalAkhir.value != null;

  Future<List<PengelolaanSampahModel>> _fetchDataLaporan() async {
    var query = SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('''
          *,
          kategori_sampah(*),
          sub_kategori_sampah(*),
          jenis_sampah(*),
          satuan(*),
          bank_sampah(nama, rt, rw),
          profiles(nama_lengkap)
        ''')
        .gte(
          'tanggal_pengelolaan',
          FormatHelper.dateToInput(selectedTanggalMulai.value!),
        )
        .lte(
          'tanggal_pengelolaan',
          FormatHelper.dateToInput(selectedTanggalAkhir.value!),
        );

    if (selectedBankSampah.value != null) {
      query = query.eq('bank_sampah_id', selectedBankSampah.value!.id);
    }

    final data = await query.order('tanggal_pengelolaan', ascending: true);
    return (data as List)
        .map((e) => PengelolaanSampahModel.fromJson(e))
        .toList();
  }

  Future<void> previewLaporan() async {
    if (!isValid) {
      Get.snackbar('Validasi', 'Tentukan periode laporan terlebih dahulu.');
      return;
    }
    isGenerating.value = true;
    try {
      previewData.value = await _fetchDataLaporan();
      hasPreview.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data laporan.');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> exportExcel() async {
    if (!isValid) return;
    isGenerating.value = true;
    try {
      final data = await _fetchDataLaporan();
      // Export Excel menggunakan package xlsx
      // Implementasi detail di view/service terpisah
      // karena butuh platform channel untuk save file
      Get.snackbar('Info', 'Fitur export Excel akan segera tersedia.');
      _ = data; // suppress unused warning
    } catch (e) {
      Get.snackbar('Gagal', 'Export gagal.');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> exportCsv() async {
    if (!isValid) return;
    isGenerating.value = true;
    try {
      final data = await _fetchDataLaporan();
      Get.snackbar('Info', 'Fitur export CSV akan segera tersedia.');
      _ = data;
    } catch (e) {
      Get.snackbar('Gagal', 'Export gagal.');
    } finally {
      isGenerating.value = false;
    }
  }
}
