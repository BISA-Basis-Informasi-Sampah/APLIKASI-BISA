import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/harga_sampah_model.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/tipe_sampah_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/satuan_model.dart';
import '../../app/routes/app_routes.dart';

class HargaController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final hargaController = TextEditingController();

  final listHarga = <HargaSampahModel>[].obs;
  final listKategori = <KategoriModel>[].obs;
  final listSubKategori = <SubKategoriModel>[].obs;
  final listTipe = <TipeSampahModel>[].obs;
  final listJenisSampah = <JenisSampahModel>[].obs;
  final listSatuan = <SatuanModel>[].obs;

  final selectedKategoriId = ''.obs;
  final selectedSubKategoriId = ''.obs;
  final selectedTipeId = ''.obs;
  final selectedJenisId = ''.obs;
  final selectedSatuanId = ''.obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  HargaSampahModel? _editData;
  bool get isEditMode => _editData != null;

  // FIX: gunakan getter yang bisa null agar bisa di-guard
  String? get _bankSampahId => SessionService.to.activeBankSampahIdOrNull;

  Map<String, List<HargaSampahModel>> get hargaPerKategori {
    final Map<String, List<HargaSampahModel>> result = {};
    for (final h in listHarga) {
      final key = h.kategori?.nama ?? 'Tanpa Kategori';
      result.putIfAbsent(key, () => []).add(h);
    }
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    // FIX: guard jika bank sampah belum dipilih
    if (_bankSampahId == null) {
      Get.offAllNamed(AppRoutes.pilihBankSampah);
      return;
    }
    fetchAll();
    ever(selectedKategoriId, (_) => _onKategoriChanged());
    ever(selectedSubKategoriId, (_) => _onSubKategoriChanged());
    ever(selectedTipeId, (_) => _onTipeChanged());
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      await Future.wait([fetchHarga(), _fetchKategori(), _fetchSatuan()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHarga() async {
    final id = _bankSampahId;
    if (id == null) return;
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableHargaSampah)
        .select(
            '*, kategori_sampah(*), sub_kategori_sampah(*), tipe_sampah(*), jenis_sampah(*), satuan(*)')
        .eq('bank_sampah_id', id)
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

  Future<void> _fetchTipe(String subKategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableTipeSampah)
        .select()
        .eq('sub_kategori_id', subKategoriId)
        .eq('is_active', true)
        .order('urutan');
    listTipe.value =
        (data as List).map((e) => TipeSampahModel.fromJson(e)).toList();
  }

  Future<void> _fetchJenisByTipe(String tipeId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select()
        .eq('tipe_id', tipeId)
        .eq('is_active', true)
        .order('urutan');
    listJenisSampah.value =
        (data as List).map((e) => JenisSampahModel.fromJson(e)).toList();
  }

  Future<void> _fetchJenisBySubKategori(String subKategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select()
        .eq('sub_kategori_id', subKategoriId)
        .isFilter('tipe_id', null)
        .eq('is_active', true)
        .order('urutan');
    listJenisSampah.value =
        (data as List).map((e) => JenisSampahModel.fromJson(e)).toList();
  }

  Future<void> _fetchJenisByKategori(String kategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select()
        .eq('kategori_id', kategoriId)
        .isFilter('sub_kategori_id', null)
        .isFilter('tipe_id', null)
        .eq('is_active', true)
        .order('urutan');
    listJenisSampah.value =
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
    selectedSubKategoriId.value = '';
    selectedTipeId.value = '';
    selectedJenisId.value = '';
    listSubKategori.clear();
    listTipe.clear();
    listJenisSampah.clear();
    if (selectedKategoriId.value.isNotEmpty) {
      _fetchSubKategori(selectedKategoriId.value).then((_) {
        if (listSubKategori.isEmpty) {
          _fetchJenisByKategori(selectedKategoriId.value);
        }
      });
    }
  }

  void _onSubKategoriChanged() {
    selectedTipeId.value = '';
    selectedJenisId.value = '';
    listTipe.clear();
    listJenisSampah.clear();
    if (selectedSubKategoriId.value.isNotEmpty) {
      _fetchTipe(selectedSubKategoriId.value).then((_) {
        if (listTipe.isEmpty) {
          _fetchJenisBySubKategori(selectedSubKategoriId.value);
        }
      });
    }
  }

  void _onTipeChanged() {
    selectedJenisId.value = '';
    listJenisSampah.clear();
    if (selectedTipeId.value.isNotEmpty) {
      _fetchJenisByTipe(selectedTipeId.value);
    }
  }

  void onKategoriChanged(String? id) => selectedKategoriId.value = id ?? '';
  void onSubKategoriChanged(String? id) =>
      selectedSubKategoriId.value = id ?? '';
  void onTipeChanged(String? id) => selectedTipeId.value = id ?? '';

  void resetForm() {
    formKey.currentState?.reset();
    hargaController.clear();
    selectedKategoriId.value = '';
    selectedSubKategoriId.value = '';
    selectedTipeId.value = '';
    selectedJenisId.value = '';
    selectedSatuanId.value = '';
    listSubKategori.clear();
    listTipe.clear();
    listJenisSampah.clear();
    _editData = null;
  }

  void initEdit(HargaSampahModel data) {
    _editData = data;
    hargaController.text = data.hargaPerSatuan.toString();
    selectedKategoriId.value = data.kategoriId ?? '';
    selectedSubKategoriId.value = data.subKategoriId ?? '';
    selectedTipeId.value = data.tipeId ?? '';
    selectedJenisId.value = data.jenisSampahId ?? '';
    selectedSatuanId.value = data.satuanId;

    if (data.kategoriId != null) {
      _fetchSubKategori(data.kategoriId!).then((_) {
        if (data.subKategoriId != null) {
          _fetchTipe(data.subKategoriId!).then((_) {
            if (data.tipeId != null) {
              _fetchJenisByTipe(data.tipeId!);
            } else if (listTipe.isEmpty) {
              _fetchJenisBySubKategori(data.subKategoriId!);
            }
          });
        } else if (listSubKategori.isEmpty) {
          _fetchJenisByKategori(data.kategoriId!);
        }
      });
    }
  }

  Future<void> simpan() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategoriId.value.isEmpty) {
      Get.snackbar('Validasi', 'Minimal pilih kategori.');
      return;
    }
    if (selectedSatuanId.value.isEmpty) {
      Get.snackbar('Validasi', 'Satuan wajib dipilih.');
      return;
    }

    final id = _bankSampahId;
    if (id == null) {
      Get.offAllNamed(AppRoutes.pilihBankSampah);
      return;
    }

    isSaving.value = true;
    try {
      final payload = {
        'bank_sampah_id': id,
        'kategori_id': selectedKategoriId.value,
        'sub_kategori_id': selectedSubKategoriId.value.isEmpty
            ? null
            : selectedSubKategoriId.value,
        'tipe_id': selectedTipeId.value.isEmpty
            ? null
            : selectedTipeId.value,
        'jenis_sampah_id':
            selectedJenisId.value.isEmpty ? null : selectedJenisId.value,
        'harga_per_satuan': double.parse(hargaController.text.trim()),
        'satuan_id': selectedSatuanId.value,
      };

      if (isEditMode) {
        await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .update(payload)
            .eq('id', _editData!.id);
        Get.snackbar('Berhasil', 'Harga berhasil diperbarui.');
      } else {
        await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .insert(payload);
        Get.snackbar('Berhasil', 'Harga berhasil ditambahkan.');
      }

      await fetchHarga();
      resetForm();
    } catch (e) {
      debugPrint('ERROR SIMPAN HARGA: $e');
      Get.snackbar('Gagal', 'Harga gagal disimpan: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteHarga(HargaSampahModel data) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Harga'),
        content: Text('Hapus harga untuk "${data.namaItem}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableHargaSampah)
          .delete()
          .eq('id', data.id);
      listHarga.removeWhere((e) => e.id == data.id);
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