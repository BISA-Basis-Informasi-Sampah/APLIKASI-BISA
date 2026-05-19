import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/bank_sampah_model.dart';
import '../../models/profile_model.dart';
import '../../app/routes/app_routes.dart';

class BankSampahController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final rtController = TextEditingController();
  final rwController = TextEditingController();
  final searchController = TextEditingController();

  final listBankSampah = <BankSampahModel>[].obs;
  final listPengelolaTerhubung = <ProfileModel>[].obs;
  final searchQuery = ''.obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isAktif = true.obs;

  final editData = Rx<BankSampahModel?>(null);
  bool get isEditMode => editData.value != null;

  // Getter list yang sudah difilter berdasarkan search
  List<BankSampahModel> get listBankFiltered {
    if (searchQuery.value.isEmpty) return listBankSampah;
    final q = searchQuery.value.toLowerCase();
    return listBankSampah.where((b) {
      return b.nama.toLowerCase().contains(q) ||
          (b.alamat?.toLowerCase().contains(q) ?? false) ||
          (b.rt?.contains(q) ?? false) ||
          (b.rw?.contains(q) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchBankSampah();
  }

  void onSearch(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> fetchBankSampah() async {
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
      Get.snackbar('Error', 'Gagal memuat daftar bank sampah.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPengelolaTerhubung(String bankSampahId) async {
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaBankSampah)
          .select('profile_id, profiles(*)')
          .eq('bank_sampah_id', bankSampahId);

      listPengelolaTerhubung.value = (data as List)
          .map(
            (e) => ProfileModel.fromJson(e['profiles'] as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      listPengelolaTerhubung.clear();
    }
  }

  // Dipanggil dari list view saat tombol edit ditekan
  void initEdit(BankSampahModel data) {
    editData.value = data;
    _populateForm();
    _fetchPengelolaTerhubung(data.id);
  }

  void _populateForm() {
    namaController.text = editData.value!.nama;
    alamatController.text = editData.value!.alamat ?? '';
    rtController.text = editData.value!.rt ?? '';
    rwController.text = editData.value!.rw ?? '';
    isAktif.value = editData.value!.isActive;
  }

  void resetForm() {
    editData.value = null;
    listPengelolaTerhubung.clear();
    formKey.currentState?.reset();
    namaController.clear();
    alamatController.clear();
    rtController.clear();
    rwController.clear();
    isAktif.value = true;
  }

  void goToForm({BankSampahModel? data}) =>
      Get.toNamed(AppRoutes.formBankSampah, arguments: data);

  Future<void> simpan() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      final payload = {
        'nama': namaController.text.trim(),
        'alamat': alamatController.text.trim().isEmpty
            ? null
            : alamatController.text.trim(),
        'rt': rtController.text.trim().isEmpty
            ? null
            : rtController.text.trim(),
        'rw': rwController.text.trim().isEmpty
            ? null
            : rwController.text.trim(),
        'is_active': isAktif.value,
      };

      if (isEditMode) {
        await SupabaseService.client
            .from(SupabaseConstants.tableBankSampah)
            .update(payload)
            .eq('id', editData.value!.id);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Bank sampah berhasil diperbarui.');
      } else {
        await SupabaseService.client
            .from(SupabaseConstants.tableBankSampah)
            .insert(payload);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Bank sampah berhasil ditambahkan.');
      }

      await fetchBankSampah();
    } catch (e) {
      Get.snackbar('Gagal', 'Data gagal disimpan.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteBank(BankSampahModel bank) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Bank Sampah'),
        content: Text(
          'Yakin ingin menghapus "${bank.nama}"? Semua data terkait akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableBankSampah)
          .delete()
          .eq('id', bank.id);
      listBankSampah.removeWhere((e) => e.id == bank.id);
      Get.snackbar('Berhasil', 'Bank sampah berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', 'Bank sampah gagal dihapus.');
    }
  }

  Future<void> toggleAktif(BankSampahModel b) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableBankSampah)
          .update({'is_active': !b.isActive})
          .eq('id', b.id);
      await fetchBankSampah();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengubah status.');
    }
  }

  Future<void> lepaskanPengelola(ProfileModel pengelola) async {
    if (editData.value == null) return;
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaBankSampah)
          .delete()
          .eq('bank_sampah_id', editData.value!.id)
          .eq('profile_id', pengelola.id);
      listPengelolaTerhubung.removeWhere((p) => p.id == pengelola.id);
      Get.snackbar('Berhasil', 'Pengelola berhasil dilepas.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal melepas pengelola.');
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    alamatController.dispose();
    rtController.dispose();
    rwController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
