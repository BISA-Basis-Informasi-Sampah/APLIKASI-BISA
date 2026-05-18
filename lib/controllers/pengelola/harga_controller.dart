import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/harga_sampah_model.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/satuan_model.dart';

class HargaController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final hargaController = TextEditingController();

  final listHarga = <HargaSampahModel>[].obs;
  final listKategori = <KategoriModel>[].obs;
  final listSubKategori = <SubKategoriModel>[].obs;
  final listJenis = <JenisSampahModel>[].obs;
  final listSatuan = <SatuanModel>[].obs;

  final selectedKategori = Rx<KategoriModel?>(null);
  final selectedSubKategori = Rx<SubKategoriModel?>(null);
  final selectedJenis = Rx<JenisSampahModel?>(null);
  final selectedSatuan = Rx<SatuanModel?>(null);

  final isLoading = false.obs;
  final isSaving = false.obs;

  String get bankSampahId => SessionService.to.activeBankSampahId;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    ever(selectedKategori, (_) => _onKategoriChanged());
    ever(selectedSubKategori, (_) => _onSubKategoriChanged());
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      await Future.wait([_fetchHarga(), _fetchKategori(), _fetchSatuan()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchHarga() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableHargaSampah)
        .select('*, kategori_sampah(*), sub_kategori_sampah(*), jenis_sampah(*), satuan(*)')
        .eq('bank_sampah_id', bankSampahId)
        .order('updated_at', ascending: false);
    listHarga.value =
        (data as List).map((e) => HargaSampahModel.fromJson(e)).toList();
  }

  Future<void> _fetchKategori() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableKategoriSampah)
        .select()
        .eq('is_active', true)
        .order('nama');
    listKategori.value =
        (data as List).map((e) => KategoriModel.fromJson(e)).toList();
  }

  Future<void> _fetchSubKategori(String kategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSubKategoriSampah)
        .select()
        .eq('kategori_id', kategoriId)
        .eq('is_active', true)
        .order('nama');
    listSubKategori.value =
        (data as List).map((e) => SubKategoriModel.fromJson(e)).toList();
  }

  Future<void> _fetchJenis(String subKategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select()
        .eq('sub_kategori_id', subKategoriId)
        .eq('is_active', true)
        .order('nama');
    listJenis.value =
        (data as List).map((e) => JenisSampahModel.fromJson(e)).toList();
  }

  Future<void> _fetchSatuan() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSatuan)
        .select()
        .order('nama');
    listSatuan.value =
        (data as List).map((e) => SatuanModel.fromJson(e)).toList();
  }

  void _onKategoriChanged() {
    selectedSubKategori.value = null;
    selectedJenis.value = null;
    listSubKategori.clear();
    listJenis.clear();
    if (selectedKategori.value != null) {
      _fetchSubKategori(selectedKategori.value!.id);
    }
  }

  void _onSubKategoriChanged() {
    selectedJenis.value = null;
    listJenis.clear();
    if (selectedSubKategori.value != null) {
      _fetchJenis(selectedSubKategori.value!.id);
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    hargaController.clear();
    selectedKategori.value = null;
    selectedSubKategori.value = null;
    selectedJenis.value = null;
    selectedSatuan.value = null;
    listSubKategori.clear();
    listJenis.clear();
  }

  Future<void> simpanHarga() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategori.value == null) {
      Get.snackbar('Validasi', 'Minimal pilih kategori.');
      return;
    }
    if (selectedSatuan.value == null) {
      Get.snackbar('Validasi', 'Satuan wajib dipilih.');
      return;
    }

    isSaving.value = true;
    try {
      final payload = {
        'bank_sampah_id': bankSampahId,
        'kategori_id': selectedKategori.value?.id,
        'sub_kategori_id': selectedSubKategori.value?.id,
        'jenis_sampah_id': selectedJenis.value?.id,
        'harga_per_satuan': double.parse(hargaController.text.trim()),
        'satuan_id': selectedSatuan.value!.id,
      };

      // Upsert: update kalau sudah ada, insert kalau belum
      await SupabaseService.client
          .from(SupabaseConstants.tableHargaSampah)
          .upsert(payload, onConflict: 'bank_sampah_id,kategori_id,sub_kategori_id,jenis_sampah_id');

      await _fetchHarga();
      resetForm();
      Get.snackbar('Berhasil', 'Harga berhasil disimpan.');
    } catch (e) {
      Get.snackbar('Gagal', 'Harga gagal disimpan.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> hapusHarga(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableHargaSampah)
          .delete()
          .eq('id', id);
      listHarga.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Harga berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', 'Harga gagal dihapus.');
    }
  }

  @override
  void onClose() {
    hargaController.dispose();
    super.onClose();
  }
}
