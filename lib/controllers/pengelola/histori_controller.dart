import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/pengelolaan_sampah_model.dart';
import '../../models/kategori_model.dart';
import '../../app/routes/app_routes.dart';

class HistoriController extends GetxController {
  final listHistori = <PengelolaanSampahModel>[].obs;
  final listKategori = <KategoriModel>[].obs;
  final isLoading = false.obs;

  // Filter
  final selectedKategoriId = Rx<String?>(null);
  final selectedTanggalMulai = Rx<DateTime?>(null);
  final selectedTanggalAkhir = Rx<DateTime?>(null);
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistori();
    _fetchKategori();
  }

  Future<void> fetchHistori() async {
    isLoading.value = true;
    try {
      final bankSampahId = SessionService.to.activeBankSampahId;

      var query = SupabaseService.client
          .from(SupabaseConstants.tablePengelolaanSampah)
          .select('''
            *,
            kategori_sampah(*),
            sub_kategori_sampah(*),
            jenis_sampah(*),
            satuan(*)
          ''')
          .eq('bank_sampah_id', bankSampahId);

      // Filter kategori
      if (selectedKategoriId.value != null) {
        query = query.eq('kategori_id', selectedKategoriId.value!);
      }

      // Filter tanggal
      if (selectedTanggalMulai.value != null) {
        query = query.gte(
          'tanggal_pengelolaan',
          selectedTanggalMulai.value!.toIso8601String().split('T').first,
        );
      }
      if (selectedTanggalAkhir.value != null) {
        query = query.lte(
          'tanggal_pengelolaan',
          selectedTanggalAkhir.value!.toIso8601String().split('T').first,
        );
      }

      final data = await query.order('tanggal_pengelolaan', ascending: false);

      listHistori.value = (data as List)
          .map((e) => PengelolaanSampahModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat histori.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchKategori() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableKategoriSampah)
        .select()
        .eq('is_active', true)
        .order('nama');
    listKategori.value = (data as List)
        .map((e) => KategoriModel.fromJson(e))
        .toList();
  }

  List<PengelolaanSampahModel> get filteredHistori {
    if (searchQuery.value.isEmpty) return listHistori;
    final q = searchQuery.value.toLowerCase();
    return listHistori.where((item) {
      return item.namaItem.toLowerCase().contains(q) ||
          item.breadcrumb.toLowerCase().contains(q) ||
          (item.catatan?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void setKategoriFilter(String? id) {
    selectedKategoriId.value = id;
    fetchHistori();
  }

  void setTanggalFilter(DateTime? mulai, DateTime? akhir) {
    selectedTanggalMulai.value = mulai;
    selectedTanggalAkhir.value = akhir;
    fetchHistori();
  }

  void resetFilter() {
    selectedKategoriId.value = null;
    selectedTanggalMulai.value = null;
    selectedTanggalAkhir.value = null;
    searchQuery.value = '';
    fetchHistori();
  }

  void goToEdit(PengelolaanSampahModel data) async {
    final result = await Get.toNamed(AppRoutes.inputSampah, arguments: data);
    if (result == true) fetchHistori();
  }

  Future<void> hapus(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaanSampah)
          .delete()
          .eq('id', id);
      listHistori.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Data berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', 'Data gagal dihapus.');
    }
  }

  Future<void> refresh() => fetchHistori();
}
