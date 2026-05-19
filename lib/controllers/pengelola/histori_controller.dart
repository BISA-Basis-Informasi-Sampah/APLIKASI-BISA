import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/utils/format_helper.dart';
import '../../models/pengelolaan_sampah_model.dart';
import '../../models/kategori_model.dart';
import '../../app/routes/app_routes.dart';

class HistoriController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  final listHistori = <PengelolaanSampahModel>[].obs;
  final listKategoriFilter = <KategoriModel>[].obs;
  final isLoading = false.obs;

  // Filter
  final filterKategoriId = ''.obs;
  final filterTanggalMulai = Rx<DateTime?>(null);
  final filterTanggalAkhir = Rx<DateTime?>(null);

  bool get isFilterActive =>
      filterKategoriId.value.isNotEmpty ||
      filterTanggalMulai.value != null ||
      filterTanggalAkhir.value != null;

  double get totalNilai =>
      listHistori.fold(0.0, (sum, e) => sum + (e.totalHarga ?? 0.0));

  @override
  void onInit() {
    super.onInit();
    fetchHistori();
    _fetchKategori();
  }

  void onSearch(String value) => searchQuery.value = value;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> fetchHistori() async {
    // FIX: guard jika bank sampah belum dipilih
    final bankSampahId = SessionService.to.activeBankSampahIdOrNull;
    if (bankSampahId == null) {
      Get.offAllNamed(AppRoutes.pilihBankSampah);
      return;
    }

    isLoading.value = true;
    try {
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

      if (filterKategoriId.value.isNotEmpty) {
        query = query.eq('kategori_id', filterKategoriId.value);
      }
      if (filterTanggalMulai.value != null) {
        query = query.gte(
          'tanggal_pengelolaan',
          filterTanggalMulai.value!.toIso8601String().split('T').first,
        );
      }
      if (filterTanggalAkhir.value != null) {
        query = query.lte(
          'tanggal_pengelolaan',
          filterTanggalAkhir.value!.toIso8601String().split('T').first,
        );
      }

      final data =
          await query.order('tanggal_pengelolaan', ascending: false);

      var list = (data as List)
          .map((e) => PengelolaanSampahModel.fromJson(e))
          .toList();

      if (searchQuery.value.isNotEmpty) {
        final q = searchQuery.value.toLowerCase();
        list = list.where((item) {
          return item.namaItem.toLowerCase().contains(q) ||
              item.breadcrumb.toLowerCase().contains(q) ||
              (item.catatan?.toLowerCase().contains(q) ?? false);
        }).toList();
      }

      listHistori.value = list;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat histori.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchKategori() async {
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableKategoriSampah)
          .select()
          .eq('is_active', true)
          .order('nama');
      listKategoriFilter.value =
          (data as List).map((e) => KategoriModel.fromJson(e)).toList();
    } catch (_) {}
  }

  Future<void> pickTanggalMulai(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterTanggalMulai.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) filterTanggalMulai.value = picked;
  }

  Future<void> pickTanggalAkhir(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterTanggalAkhir.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) filterTanggalAkhir.value = picked;
  }

  void applyFilter() => fetchHistori();

  void resetFilter() {
    filterKategoriId.value = '';
    filterTanggalMulai.value = null;
    filterTanggalAkhir.value = null;
    searchController.clear();
    searchQuery.value = '';
    fetchHistori();
  }

  Future<void> editItem(PengelolaanSampahModel data) async {
    final result = await Get.toNamed(AppRoutes.inputSampah, arguments: data);
    if (result == true) fetchHistori();
  }

  Future<void> deleteItem(PengelolaanSampahModel data) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaanSampah)
          .delete()
          .eq('id', data.id);
      listHistori.removeWhere((e) => e.id == data.id);
      Get.snackbar('Berhasil', 'Data berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', 'Data gagal dihapus.');
    }
  }

  Future<void> refresh() => fetchHistori();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}