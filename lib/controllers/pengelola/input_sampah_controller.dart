import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/utils/format_helper.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/tipe_sampah_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/satuan_model.dart';
import '../../models/harga_sampah_model.dart';
import '../../models/pengelolaan_sampah_model.dart';

class InputSampahController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final jumlahController          = TextEditingController();
  final hargaPerSatuanController  = TextEditingController();
  final catatanController         = TextEditingController();
  final tanggalController         = TextEditingController();
  final totalHargaController      = TextEditingController();

  // Data list
  final listKategori    = <KategoriModel>[].obs;
  final listSubKategori = <SubKategoriModel>[].obs;
  final listTipe        = <TipeSampahModel>[].obs;   // ← BARU
  final listJenisSampah = <JenisSampahModel>[].obs;
  final listSatuan      = <SatuanModel>[].obs;

  // State dropdown
  final selectedKategoriId    = ''.obs;
  final selectedSubKategoriId = ''.obs;
  final selectedTipeId        = ''.obs;              // ← BARU
  final selectedJenisId       = ''.obs;
  final selectedSatuanId      = ''.obs;

  // Tanggal
  final selectedTanggal = Rx<DateTime?>(DateTime.now());

  // Harga snapshot otomatis dari tabel harga_sampah
  final hargaSnapshot = Rx<HargaSampahModel?>(null);

  // Estimasi reactive variables
  final rxJumlah = 0.0.obs;
  final rxHargaPerSatuan = 0.0.obs;

  // Loading state
  final isLoading = false.obs;

  // Guard untuk mencegah ever() trigger saat populateEditData
  bool _isPopulating = false;

  // Edit mode
  PengelolaanSampahModel? editData;
  bool get isEditMode => editData != null;

  @override
  void onInit() {
    super.onInit();
    _checkEditMode();
    _fetchMasterData();

    // Listener cascade dropdown — skip saat sedang populate edit data
    ever(selectedKategoriId,    (_) { if (!_isPopulating) _onKategoriChanged(); });
    ever(selectedSubKategoriId, (_) { if (!_isPopulating) _onSubKategoriChanged(); });
    ever(selectedTipeId,        (_) { if (!_isPopulating) _onTipeChanged(); });     // ← BARU
    ever(selectedJenisId,       (_) { if (!_isPopulating) _onJenisChanged(); });

    // Listeners untuk update estimasi total secara real-time
    jumlahController.addListener(_updateEstimasi);
    hargaPerSatuanController.addListener(_updateEstimasi);
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
      if (isEditMode) {
        _populateEditData();
      } else {
        if (selectedTanggal.value != null) {
          tanggalController.text = FormatHelper.date(selectedTanggal.value!);
        }
      }
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
        .order('urutan');
    listKategori.value =
        (data as List).map((e) => KategoriModel.fromJson(e)).toList();
  }

  Future<void> _fetchSubKategori(String kategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSubKategoriSampah)
        .select()
        .eq('kategori_id', kategoriId)
        .eq('is_active', true)
        .order('urutan');
    listSubKategori.value =
        (data as List).map((e) => SubKategoriModel.fromJson(e)).toList();
  }

  // ← BARU: fetch tipe berdasarkan sub_kategori_id
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

  // Fetch jenis berdasarkan tipe_id
  Future<void> _fetchJenisByTipe(String tipeId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select('*, satuan(*)')
        .eq('tipe_id', tipeId)
        .eq('is_active', true)
        .order('urutan');
    listJenisSampah.value =
        (data as List).map((e) => JenisSampahModel.fromJson(e)).toList();
  }

  // Fetch jenis langsung dari sub_kategori (Kertas, Logam, Kaca — tanpa tipe)
  Future<void> _fetchJenisBySubKategori(String subKategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select('*, satuan(*)')
        .eq('sub_kategori_id', subKategoriId)
        .isFilter('tipe_id', null)
        .eq('is_active', true)
        .order('urutan');
    listJenisSampah.value =
        (data as List).map((e) => JenisSampahModel.fromJson(e)).toList();
  }

  // Fetch jenis langsung dari kategori (Organik, Minyak Jelantah)
  Future<void> _fetchJenisByKategori(String kategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select('*, satuan(*)')
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

  Future<void> _fetchHargaOtomatis() async {
    final bankSampahId = SessionService.to.activeBankSampahId;
    hargaSnapshot.value = null;

    try {
      dynamic data;

      if (selectedJenisId.value.isNotEmpty) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('jenis_sampah_id', selectedJenisId.value)
            .maybeSingle();
      }

      if (data == null && selectedTipeId.value.isNotEmpty) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('tipe_id', selectedTipeId.value)
            .isFilter('jenis_sampah_id', null)
            .maybeSingle();
      }

      if (data == null && selectedSubKategoriId.value.isNotEmpty) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('sub_kategori_id', selectedSubKategoriId.value)
            .isFilter('tipe_id', null)
            .isFilter('jenis_sampah_id', null)
            .maybeSingle();
      }

      if (data == null && selectedKategoriId.value.isNotEmpty) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('kategori_id', selectedKategoriId.value)
            .isFilter('sub_kategori_id', null)
            .isFilter('tipe_id', null)
            .isFilter('jenis_sampah_id', null)
            .maybeSingle();
      }

      if (data != null) {
        hargaSnapshot.value = HargaSampahModel.fromJson(data);
        hargaPerSatuanController.text =
            hargaSnapshot.value!.hargaPerSatuan.toStringAsFixed(0);
        if (hargaSnapshot.value?.satuanId != null &&
            selectedSatuanId.value.isEmpty) {
          selectedSatuanId.value = hargaSnapshot.value!.satuanId;
        }
      }
    } catch (_) {
      // Harga tidak ditemukan, tidak masalah
    }
  }

  // ── Cascade handlers ──────────────────────────────────────────────────────

  void _onKategoriChanged() {
    selectedSubKategoriId.value = '';
    selectedTipeId.value = '';
    selectedJenisId.value = '';
    listSubKategori.clear();
    listTipe.clear();
    listJenisSampah.clear();
    hargaSnapshot.value = null;

    if (selectedKategoriId.value.isNotEmpty) {
      _fetchSubKategori(selectedKategoriId.value).then((_) {
        // Jika tidak ada sub kategori → langsung fetch jenis dari kategori
        // (kasus Organik, Minyak Jelantah)
        if (listSubKategori.isEmpty) {
          _fetchJenisByKategori(selectedKategoriId.value);
        }
      });
      _fetchHargaOtomatis();
    }
  }

  void _onSubKategoriChanged() {
    selectedTipeId.value = '';
    selectedJenisId.value = '';
    listTipe.clear();
    listJenisSampah.clear();

    if (selectedSubKategoriId.value.isNotEmpty) {
      // Coba fetch tipe dulu; kalau kosong, langsung fetch jenis
      _fetchTipe(selectedSubKategoriId.value).then((_) {
        if (listTipe.isEmpty) {
          _fetchJenisBySubKategori(selectedSubKategoriId.value);
        }
      });
    }
    _fetchHargaOtomatis();
  }

  void _onTipeChanged() {
    selectedJenisId.value = '';
    listJenisSampah.clear();

    if (selectedTipeId.value.isNotEmpty) {
      _fetchJenisByTipe(selectedTipeId.value);
    }
    _fetchHargaOtomatis();
  }

  void _onJenisChanged() {
    if (selectedJenisId.value.isNotEmpty) {
      final jenis = listJenisSampah.firstWhereOrNull(
        (j) => j.id == selectedJenisId.value,
      );
      if (jenis?.satuanDefaultId != null && selectedSatuanId.value.isEmpty) {
        selectedSatuanId.value = jenis!.satuanDefaultId!;
      }
    }
    _fetchHargaOtomatis();
  }

  // ── Callback untuk dropdown view ────────────────────────────────────────────

  void onKategoriChanged(String? id)    => selectedKategoriId.value    = id ?? '';
  void onSubKategoriChanged(String? id) => selectedSubKategoriId.value = id ?? '';
  void onTipeChanged(String? id)        => selectedTipeId.value        = id ?? '';   // ← BARU
  void onJenisChanged(String? id)       => selectedJenisId.value       = id ?? '';

  // ── Populate data saat edit ──────────────────────────────────────────────────

  Future<void> _populateEditData() async {
    final d = editData!;
    _isPopulating = true;

    selectedTanggal.value   = d.tanggalPengelolaan;
    tanggalController.text  = FormatHelper.date(d.tanggalPengelolaan);
    jumlahController.text   = d.jumlah.toString();
    hargaPerSatuanController.text =
        d.hargaPerSatuan != null ? d.hargaPerSatuan.toString() : '';
    catatanController.text  = d.catatan ?? '';
    selectedSatuanId.value  = d.satuanId;

    // Kategori
    if (d.kategoriId.isNotEmpty) {
      selectedKategoriId.value = d.kategoriId;
      await _fetchSubKategori(d.kategoriId);

      if (d.subKategoriId != null) {
        selectedSubKategoriId.value = d.subKategoriId!;
        await _fetchTipe(d.subKategoriId!);

        // Ada tipe?
        if (d.tipeId != null) {
          selectedTipeId.value = d.tipeId!;
          await _fetchJenisByTipe(d.tipeId!);
        } else if (listTipe.isEmpty) {
          // Tidak ada tipe → ambil jenis langsung dari sub_kategori
          await _fetchJenisBySubKategori(d.subKategoriId!);
        }
      } else if (listSubKategori.isEmpty) {
        // Tidak ada sub_kategori → ambil jenis langsung dari kategori
        await _fetchJenisByKategori(d.kategoriId);
      }

      if (d.jenisSampahId != null) {
        selectedJenisId.value = d.jenisSampahId!;
      }
    }

    _isPopulating = false;
    _fetchHargaOtomatis();
  }

  // ── Date picker ──────────────────────────────────────────────────────────────

  Future<void> pickTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTanggal.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedTanggal.value  = picked;
      tanggalController.text = FormatHelper.date(picked);
    }
  }

  void clearTanggal() {
    selectedTanggal.value = null;
    tanggalController.clear();
  }

  // ── Simpan ───────────────────────────────────────────────────────────────────

  Future<void> simpan() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategoriId.value.isEmpty) {
      Get.snackbar('Validasi', 'Kategori wajib dipilih.');
      return;
    }
    // Sub kategori wajib jika ada pilihannya (An Organik)
    if (listSubKategori.isNotEmpty && selectedSubKategoriId.value.isEmpty) {
      Get.snackbar('Validasi', 'Sub Kategori wajib dipilih.');
      return;
    }
    // Tipe wajib jika ada pilihannya (Plastik)
    if (listTipe.isNotEmpty && selectedTipeId.value.isEmpty) {
      Get.snackbar('Validasi', 'Tipe wajib dipilih.');
      return;
    }
    // Jenis wajib jika ada pilihannya
    if (listJenisSampah.isNotEmpty && selectedJenisId.value.isEmpty) {
      Get.snackbar('Validasi', 'Jenis Sampah wajib dipilih.');
      return;
    }
    if (selectedSatuanId.value.isEmpty) {
      Get.snackbar('Validasi', 'Satuan wajib dipilih.');
      return;
    }
    if (selectedTanggal.value == null) {
      Get.snackbar('Validasi', 'Tanggal wajib diisi.');
      return;
    }

    final bankSampahId = SessionService.to.activeBankSampahId;
    final profileId = SessionService.to.profile.value?.id ?? '';

    if (bankSampahId.isEmpty) {
      Get.snackbar('Validasi', 'ID Bank Sampah tidak ditemukan. Silakan pilih bank sampah terlebih dahulu.');
      return;
    }
    if (profileId.isEmpty) {
      Get.snackbar('Validasi', 'ID Profil tidak ditemukan. Silakan login ulang.');
      return;
    }

    isLoading.value = true;
    try {
      final jumlah = double.parse(
          jumlahController.text.trim().replaceAll(',', '.'));
      final totalHargaInput = double.tryParse(
          totalHargaController.text.trim().replaceAll(',', '.'));
      final hargaPerSatuanInput = double.tryParse(
          hargaPerSatuanController.text.trim().replaceAll(',', '.'));

      // Karena total_harga adalah generated column di database PostgreSQL,
      // kita tidak boleh memasukkannya ke dalam payload insert/update.
      // Kita cukup mengirimkan harga_per_satuan dan jumlah, dan database akan menghitung total_harga secara otomatis.
      double hargaPerSatuan = 0.0;
      if (totalHargaInput != null && totalHargaInput > 0) {
        hargaPerSatuan = totalHargaInput / (jumlah > 0 ? jumlah : 1.0);
      } else if (hargaPerSatuanInput != null) {
        hargaPerSatuan = hargaPerSatuanInput;
      }

      final payload = {
        'bank_sampah_id': bankSampahId,
        'profile_id':     profileId,
        'kategori_id':    selectedKategoriId.value.trim(),
        'sub_kategori_id': selectedSubKategoriId.value.trim().isEmpty
            ? null
            : selectedSubKategoriId.value.trim(),
        'tipe_id': selectedTipeId.value.trim().isEmpty
            ? null
            : selectedTipeId.value.trim(),
        'jenis_sampah_id': selectedJenisId.value.trim().isEmpty
            ? null
            : selectedJenisId.value.trim(),
        'jumlah':          jumlah,
        'satuan_id':       selectedSatuanId.value.trim(),
        'harga_per_satuan': hargaPerSatuan,
        'tanggal_pengelolaan':
            FormatHelper.dateToInput(selectedTanggal.value!),
        'catatan': catatanController.text.trim().isEmpty
            ? null
            : catatanController.text.trim(),
      };

      debugPrint('PAYLOAD PENYIMPANAN: $payload');

      if (isEditMode) {
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaanSampah)
            .update(payload)
            .eq('id', editData!.id);
        Get.snackbar('Berhasil', 'Data sampah berhasil diperbarui.');
      } else {
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaanSampah)
            .insert(payload);
        Get.snackbar('Berhasil', 'Data sampah berhasil disimpan.');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nav = Get.key.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop(true);
        }
      });
    } catch (e) {
      debugPrint('ERROR SIMPAN SAMPAH: $e');
      Get.snackbar('Gagal', 'Data gagal disimpan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateEstimasi() {
    rxJumlah.value =
        double.tryParse(jumlahController.text.trim().replaceAll(',', '.')) ??
            0.0;
    rxHargaPerSatuan.value = double.tryParse(
            hargaPerSatuanController.text.trim().replaceAll(',', '.')) ??
        0.0;
  }

  @override
  void onClose() {
    jumlahController.removeListener(_updateEstimasi);
    hargaPerSatuanController.removeListener(_updateEstimasi);
    jumlahController.dispose();
    hargaPerSatuanController.dispose();
    catatanController.dispose();
    tanggalController.dispose();
    totalHargaController.dispose();
    super.onClose();
  }
}