import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/bank_sampah_model.dart';
import '../../app/routes/app_routes.dart';

class BankSampahController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final rtController = TextEditingController();
  final rwController = TextEditingController();

  final listBankSampah = <BankSampahModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isAktif = true.obs;

  BankSampahModel? editData;
  bool get isEditMode => editData != null;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is BankSampahModel) {
      editData = Get.arguments as BankSampahModel;
      _populateForm();
    }
    fetchBankSampah();
  }

  void _populateForm() {
    namaController.text = editData!.nama;
    alamatController.text = editData!.alamat ?? '';
    rtController.text = editData!.rt ?? '';
    rwController.text = editData!.rw ?? '';
    isAktif.value = editData!.isActive;
  }

  Future<void> fetchBankSampah() async {
    isLoading.value = true;
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableBankSampah)
          .select()
          .order('nama');
      listBankSampah.value =
          (data as List).map((e) => BankSampahModel.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar bank sampah.');
    } finally {
      isLoading.value = false;
    }
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
        'rt': rtController.text.trim().isEmpty ? null : rtController.text.trim(),
        'rw': rwController.text.trim().isEmpty ? null : rwController.text.trim(),
        'is_active': isAktif.value,
      };

      if (isEditMode) {
        await SupabaseService.client
            .from(SupabaseConstants.tableBankSampah)
            .update(payload)
            .eq('id', editData!.id);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Bank sampah berhasil diperbarui.');
      } else {
        await SupabaseService.client
            .from(SupabaseConstants.tableBankSampah)
            .insert(payload);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Bank sampah berhasil ditambahkan.');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Data gagal disimpan.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> hapus(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableBankSampah)
          .delete()
          .eq('id', id);
      listBankSampah.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Bank sampah berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', 'Bank sampah gagal dihapus.');
    }
  }

  Future<void> toggleAktif(BankSampahModel b) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableBankSampah)
          .update({'is_active': !b.isActive}).eq('id', b.id);
      await fetchBankSampah();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengubah status.');
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    alamatController.dispose();
    rtController.dispose();
    rwController.dispose();
    super.onClose();
  }
}
