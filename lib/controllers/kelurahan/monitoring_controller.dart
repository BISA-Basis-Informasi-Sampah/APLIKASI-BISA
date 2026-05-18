import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/bank_sampah_model.dart';
import '../../models/pengelolaan_sampah_model.dart';

class MonitoringController extends GetxController {
  final listBankSampah = <BankSampahModel>[].obs;
  final isLoading = false.obs;

  // Detail bank sampah yang dipilih
  final selectedBankSampah = Rx<BankSampahModel?>(null);
  final detailTransaksi = <PengelolaanSampahModel>[].obs;
  final isLoadingDetail = false.obs;

  // Statistik per bank sampah
  final statJumlah = 0.0.obs;
  final statTransaksi = 0.obs;
  final statNilai = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Cek apakah ada argument (dari dashboard -> detail langsung)
    if (Get.arguments != null && Get.arguments is BankSampahModel) {
      selectedBankSampah.value = Get.arguments as BankSampahModel;
      fetchDetailBankSampah(selectedBankSampah.value!.id);
    } else {
      fetchSemuaBankSampah();
    }
  }

  Future<void> fetchSemuaBankSampah() async {
    isLoading.value = true;
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableBankSampah)
          .select()
          .order('nama');
      listBankSampah.value = (data as List)
          .map((e) => BankSampahModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data bank sampah.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDetailBankSampah(String bankSampahId) async {
    isLoadingDetail.value = true;
    try {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      final data = await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaanSampah)
          .select('''
            *,
            kategori_sampah(*),
            sub_kategori_sampah(*),
            jenis_sampah(*),
            satuan(*),
            profiles(nama_lengkap)
          ''')
          .eq('bank_sampah_id', bankSampahId)
          .gte(
            'tanggal_pengelolaan',
            firstDay.toIso8601String().split('T').first,
          )
          .lte(
            'tanggal_pengelolaan',
            lastDay.toIso8601String().split('T').first,
          )
          .order('tanggal_pengelolaan', ascending: false);

      final list = (data as List)
          .map((e) => PengelolaanSampahModel.fromJson(e))
          .toList();

      detailTransaksi.value = list;
      statTransaksi.value = list.length;
      statJumlah.value = list.fold(0.0, (sum, e) => sum + e.jumlah);
      statNilai.value = list.fold(0.0, (sum, e) => sum + (e.totalHarga ?? 0.0));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail bank sampah.');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> refresh() => selectedBankSampah.value != null
      ? fetchDetailBankSampah(selectedBankSampah.value!.id)
      : fetchSemuaBankSampah();
}
