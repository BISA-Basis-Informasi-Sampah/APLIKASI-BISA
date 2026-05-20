import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/tipe_sampah_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/satuan_model.dart';

class MasterSampahController extends GetxController {
  // Tab aktif: 0=Kategori, 1=Sub Kategori, 2=Tipe, 3=Jenis, 4=Satuan
  final activeTab = 0.obs;

  // Data
  final listKategori    = <KategoriModel>[].obs;
  final listSubKategori = <SubKategoriModel>[].obs;
  final listTipe        = <TipeSampahModel>[].obs;   // ← BARU
  final listJenis       = <JenisSampahModel>[].obs;
  final listSatuan      = <SatuanModel>[].obs;

  // Dropdown untuk form
  final listKategoriDropdown    = <KategoriModel>[].obs;
  final listSubKategoriDropdown = <SubKategoriModel>[].obs;
  final listTipeDropdown        = <TipeSampahModel>[].obs;   // ← BARU

  final isLoading = false.obs;
  final isSaving  = false.obs;

  // Form controllers
  final namaController       = TextEditingController();
  final deskripsiController  = TextEditingController();
  final singkatanController  = TextEditingController();
  final formKey              = GlobalKey<FormState>();

  final selectedKategoriForm    = Rx<KategoriModel?>(null);
  final selectedSubKategoriForm = Rx<SubKategoriModel?>(null);
  final selectedTipeForm        = Rx<TipeSampahModel?>(null);   // ← BARU
  final selectedSatuanForm      = Rx<SatuanModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    ever(selectedKategoriForm,    (_) => _fetchSubKategoriDropdown());
    ever(selectedSubKategoriForm, (_) => _fetchTipeDropdown());   // ← BARU
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchKategori(),
        _fetchSubKategori(),
        _fetchTipe(),
        _fetchJenis(),
        _fetchSatuan(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchKategori() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableKategoriSampah)
        .select()
        .order('urutan');
    listKategori.value =
        (data as List).map((e) => KategoriModel.fromJson(e)).toList();
    listKategoriDropdown.value = listKategori;
  }

  Future<void> _fetchSubKategori() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSubKategoriSampah)
        .select('*, kategori_sampah(*)')
        .order('urutan');
    listSubKategori.value =
        (data as List).map((e) => SubKategoriModel.fromJson(e)).toList();
  }

  Future<void> _fetchTipe() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableTipeSampah)
        .select('*, sub_kategori_sampah(*)')
        .order('urutan');
    listTipe.value =
        (data as List).map((e) => TipeSampahModel.fromJson(e)).toList();
  }

  Future<void> _fetchJenis() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select('*, sub_kategori_sampah(*, kategori_sampah(*)), tipe_sampah(*), kategori_sampah(*), satuan(*)')
        .order('urutan');
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

  Future<void> _fetchSubKategoriDropdown() async {
    if (selectedKategoriForm.value == null) {
      listSubKategoriDropdown.clear();
      listTipeDropdown.clear();
      return;
    }
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSubKategoriSampah)
        .select()
        .eq('kategori_id', selectedKategoriForm.value!.id)
        .order('urutan');
    listSubKategoriDropdown.value =
        (data as List).map((e) => SubKategoriModel.fromJson(e)).toList();
    listTipeDropdown.clear();
    selectedSubKategoriForm.value = null;
    selectedTipeForm.value = null;
  }

  Future<void> _fetchTipeDropdown() async {
    selectedTipeForm.value = null;
    listTipeDropdown.clear();
    if (selectedSubKategoriForm.value == null) return;
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableTipeSampah)
        .select()
        .eq('sub_kategori_id', selectedSubKategoriForm.value!.id)
        .order('urutan');
    listTipeDropdown.value =
        (data as List).map((e) => TipeSampahModel.fromJson(e)).toList();
  }

  void resetForm() {
    formKey.currentState?.reset();
    namaController.clear();
    deskripsiController.clear();
    singkatanController.clear();
    selectedKategoriForm.value    = null;
    selectedSubKategoriForm.value = null;
    selectedTipeForm.value        = null;
    selectedSatuanForm.value      = null;
    listSubKategoriDropdown.clear();
    listTipeDropdown.clear();
  }

  // ── Simpan ─────────────────────────────────────────────────────────────────

  Future<void> simpanKategori() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableKategoriSampah)
          .insert({
        'nama': namaController.text.trim(),
        'deskripsi': deskripsiController.text.trim().isEmpty
            ? null
            : deskripsiController.text.trim(),
      });
      await _fetchKategori();
      resetForm();
      Get.snackbar('Berhasil', 'Kategori berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Gagal menyimpan kategori: ${_mapPostgrestError(e)}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> simpanSubKategori() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategoriForm.value == null) {
      Get.snackbar('Validasi', 'Pilih kategori terlebih dahulu.');
      return;
    }
    isSaving.value = true;
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableSubKategoriSampah)
          .insert({
        'kategori_id': selectedKategoriForm.value!.id,
        'nama': namaController.text.trim(),
        'deskripsi': deskripsiController.text.trim().isEmpty
            ? null
            : deskripsiController.text.trim(),
      });
      await _fetchSubKategori();
      resetForm();
      Get.snackbar('Berhasil', 'Sub kategori berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Gagal menyimpan sub kategori: ${_mapPostgrestError(e)}');
    } finally {
      isSaving.value = false;
    }
  }

  // ← BARU
  Future<void> simpanTipe() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedSubKategoriForm.value == null) {
      Get.snackbar('Validasi', 'Pilih sub kategori terlebih dahulu.');
      return;
    }
    isSaving.value = true;
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableTipeSampah)
          .insert({
        'sub_kategori_id': selectedSubKategoriForm.value!.id,
        'nama': namaController.text.trim(),
        'deskripsi': deskripsiController.text.trim().isEmpty
            ? null
            : deskripsiController.text.trim(),
      });
      await _fetchTipe();
      resetForm();
      Get.snackbar('Berhasil', 'Tipe berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Gagal menyimpan tipe: ${_mapPostgrestError(e)}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> simpanJenis() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableJenisSampah)
          .insert({
        'sub_kategori_id': selectedSubKategoriForm.value?.id,
        'tipe_id':         selectedTipeForm.value?.id,
        'kategori_id':     selectedKategoriForm.value?.id,
        'nama':            namaController.text.trim(),
        'deskripsi': deskripsiController.text.trim().isEmpty
            ? null
            : deskripsiController.text.trim(),
        'satuan_default_id': selectedSatuanForm.value?.id,
      });
      await _fetchJenis();
      resetForm();
      Get.snackbar('Berhasil', 'Jenis sampah berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Gagal menyimpan jenis sampah: ${_mapPostgrestError(e)}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> simpanSatuan() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    try {
      await SupabaseService.client.from(SupabaseConstants.tableSatuan).insert({
        'nama':       namaController.text.trim(),
        'singkatan':  singkatanController.text.trim(),
      });
      await _fetchSatuan();
      resetForm();
      Get.snackbar('Berhasil', 'Satuan berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Gagal menyimpan satuan: ${_mapPostgrestError(e)}');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Hapus ──────────────────────────────────────────────────────────────────

  Future<void> hapusKategori(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableKategoriSampah)
          .delete()
          .eq('id', id);
      listKategori.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Kategori dihapus.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Kategori tidak bisa dihapus karena masih digunakan.');
    }
  }

  Future<void> hapusSubKategori(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableSubKategoriSampah)
          .delete()
          .eq('id', id);
      listSubKategori.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Sub kategori dihapus.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Sub kategori tidak bisa dihapus karena masih digunakan.');
    }
  }

  // ← BARU
  Future<void> hapusTipe(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableTipeSampah)
          .delete()
          .eq('id', id);
      listTipe.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Tipe dihapus.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Tipe tidak bisa dihapus karena masih digunakan.');
    }
  }

  Future<void> hapusJenis(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableJenisSampah)
          .delete()
          .eq('id', id);
      listJenis.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Jenis sampah dihapus.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Jenis sampah tidak bisa dihapus karena masih digunakan.');
    }
  }

  Future<void> hapusSatuan(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableSatuan)
          .delete()
          .eq('id', id);
      listSatuan.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Satuan dihapus.');
    } catch (e) {
      Get.snackbar('Gagal',
          'Satuan tidak bisa dihapus karena masih digunakan.');
    }
  }

  String _mapPostgrestError(dynamic e) {
    if (e is PostgrestException) {
      if (e.code == '23505') return 'Data dengan nama tersebut sudah terdaftar.';
      return e.message;
    }
    return e.toString();
  }

  @override
  void onClose() {
    namaController.dispose();
    deskripsiController.dispose();
    singkatanController.dispose();
    super.onClose();
  }
}