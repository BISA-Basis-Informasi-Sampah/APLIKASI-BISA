import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/utils/format_helper.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/satuan_model.dart';
import '../../models/harga_sampah_model.dart';
import '../../models/pengelolaan_sampah_model.dart';

class InputSampahController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final jumlahController = TextEditingController();
  final catatanController = TextEditingController();

  // State dropdown
  final listKategori = <KategoriModel>[].obs;
  final listSubKategori = <SubKategoriModel>[].obs;
  final listJenis = <JenisSampahModel>[].obs;
  final listSatuan = <SatuanModel>[].obs;

  final selectedKategori = Rx<KategoriModel?>(null);
  final selectedSubKategori = Rx<SubKategoriModel?>(null);
  final selectedJenis = Rx<JenisSampahModel?>(null);
  final selectedSatuan = Rx<SatuanModel?>(null);
  final selectedTanggal = Rx<DateTime?>(DateTime.now());

  // Harga otomatis dari tabel harga_sampah
  final hargaDitemukan = Rx<HargaSampahModel?>(null);

  final isLoading = false.obs;
  final isSaving = false.obs;

  // Edit mode
  PengelolaanSampahModel? editData;
  bool get isEditMode => editData != null;

  @override
  void onInit() {
    super.onInit();
    _checkEditMode();
    _fetchMasterData();

    // Listener cascade dropdown
    ever(selectedKategori, (_) => _onKategoriChanged());
    ever(selectedSubKategori, (_) => _onSubKategoriChanged());
    ever(selectedJenis, (_) => _onJenisChanged());
  }

  void _checkEditMode() {
    if (Get.arguments != null && Get.arguments is PengelolaanSampahModel) {
      editData = Get.arguments as PengelolaanSampahModel;
    }
  }

  Future<void> _fetchMasterData() async {
    isLoading.value = true;
    try {
      await Future.wait([_fetchKategori(), _fetchSatuan()]);

      // Isi form jika edit mode
      if (isEditMode) _populateEditData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data master.');
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

  Future<void> _fetchSubKategori(String kategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSubKategoriSampah)
        .select()
        .eq('kategori_id', kategoriId)
        .eq('is_active', true)
        .order('nama');
    listSubKategori.value = (data as List)
        .map((e) => SubKategoriModel.fromJson(e))
        .toList();
  }

  Future<void> _fetchJenis(String subKategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select('*, satuan(*)')
        .eq('sub_kategori_id', subKategoriId)
        .eq('is_active', true)
        .order('nama');
    listJenis.value = (data as List)
        .map((e) => JenisSampahModel.fromJson(e))
        .toList();
  }

  Future<void> _fetchSatuan() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSatuan)
        .select()
        .order('nama');
    listSatuan.value = (data as List)
        .map((e) => SatuanModel.fromJson(e))
        .toList();
  }

  Future<void> _fetchHargaOtomatis() async {
    final bankSampahId = SessionService.to.activeBankSampahId;
    hargaDitemukan.value = null;

    try {
      // Cari harga dari yang paling spesifik ke paling umum
      dynamic data;

      if (selectedJenis.value != null) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('jenis_sampah_id', selectedJenis.value!.id)
            .maybeSingle();
      }

      data ??= selectedSubKategori.value != null
          ? await SupabaseService.client
                .from(SupabaseConstants.tableHargaSampah)
                .select('*, satuan(*)')
                .eq('bank_sampah_id', bankSampahId)
                .eq('sub_kategori_id', selectedSubKategori.value!.id)
                .is_('jenis_sampah_id', null)
                .maybeSingle()
          : null;

      data ??= selectedKategori.value != null
          ? await SupabaseService.client
                .from(SupabaseConstants.tableHargaSampah)
                .select('*, satuan(*)')
                .eq('bank_sampah_id', bankSampahId)
                .eq('kategori_id', selectedKategori.value!.id)
                .is_('sub_kategori_id', null)
                .is_('jenis_sampah_id', null)
                .maybeSingle()
          : null;

      if (data != null) {
        hargaDitemukan.value = HargaSampahModel.fromJson(data);
        // Auto-set satuan dari harga
        if (hargaDitemukan.value?.satuan != null) {
          final satuanMatch = listSatuan.firstWhereOrNull(
            (s) => s.id == hargaDitemukan.value!.satuanId,
          );
          if (satuanMatch != null) selectedSatuan.value = satuanMatch;
        }
      }
    } catch (_) {
      // Harga tidak ditemukan, tidak masalah
    }
  }

  void _onKategoriChanged() {
    selectedSubKategori.value = null;
    selectedJenis.value = null;
    listSubKategori.clear();
    listJenis.clear();
    hargaDitemukan.value = null;

    if (selectedKategori.value != null) {
      _fetchSubKategori(selectedKategori.value!.id);
      _fetchHargaOtomatis();
    }
  }

  void _onSubKategoriChanged() {
    selectedJenis.value = null;
    listJenis.clear();

    if (selectedSubKategori.value != null) {
      _fetchJenis(selectedSubKategori.value!.id);
      _fetchHargaOtomatis();
    } else {
      _fetchHargaOtomatis();
    }
  }

  void _onJenisChanged() {
    // Auto-set satuan default dari jenis
    if (selectedJenis.value?.satuanDefault != null) {
      final satuanMatch = listSatuan.firstWhereOrNull(
        (s) => s.id == selectedJenis.value!.satuanDefaultId,
      );
      if (satuanMatch != null) selectedSatuan.value = satuanMatch;
    }
    _fetchHargaOtomatis();
  }

  void _populateEditData() {
    final d = editData!;
    selectedTanggal.value = d.tanggalPengelolaan;
    jumlahController.text = d.jumlah.toString();
    catatanController.text = d.catatan ?? '';

    if (d.kategori != null) {
      selectedKategori.value = listKategori.firstWhereOrNull(
        (k) => k.id == d.kategoriId,
      );
    }
  }

  Future<void> pickTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTanggal.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) selectedTanggal.value = picked;
  }

  Future<void> simpan() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategori.value == null) {
      Get.snackbar('Validasi', 'Kategori wajib dipilih.');
      return;
    }
    if (selectedSatuan.value == null) {
      Get.snackbar('Validasi', 'Satuan wajib dipilih.');
      return;
    }
    if (selectedTanggal.value == null) {
      Get.snackbar('Validasi', 'Tanggal wajib diisi.');
      return;
    }

    isSaving.value = true;
    try {
      final payload = {
        'bank_sampah_id': SessionService.to.activeBankSampahId,
        'profile_id': SessionService.to.profile.value!.id,
        'kategori_id': selectedKategori.value!.id,
        'sub_kategori_id': selectedSubKategori.value?.id,
        'jenis_sampah_id': selectedJenis.value?.id,
        'jumlah': double.parse(jumlahController.text.trim()),
        'satuan_id': selectedSatuan.value!.id,
        'harga_per_satuan': hargaDitemukan.value?.hargaPerSatuan,
        'tanggal_pengelolaan': FormatHelper.dateToInput(selectedTanggal.value!),
        'catatan': catatanController.text.trim().isEmpty
            ? null
            : catatanController.text.trim(),
      };

      if (isEditMode) {
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaanSampah)
            .update(payload)
            .eq('id', editData!.id);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Data sampah berhasil diperbarui.');
      } else {
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaanSampah)
            .insert(payload);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Data sampah berhasil disimpan.');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Data gagal disimpan. Coba lagi.');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    jumlahController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}
