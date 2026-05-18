import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/profile_model.dart';
import '../../models/bank_sampah_model.dart';
import '../../app/routes/app_routes.dart';

class PengelolaController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final noHpController = TextEditingController();

  final listPengelola = <ProfileModel>[].obs;
  final listBankSampah = <BankSampahModel>[].obs;
  final selectedBankSampahIds = <String>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isPasswordVisible = false.obs;

  void togglePassword() => isPasswordVisible.value = !isPasswordVisible.value;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      await Future.wait([_fetchPengelola(), _fetchBankSampah()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPengelola() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableProfiles)
        .select()
        .eq('role', 'pengelola')
        .order('nama_lengkap');
    listPengelola.value =
        (data as List).map((e) => ProfileModel.fromJson(e)).toList();
  }

  Future<void> _fetchBankSampah() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableBankSampah)
        .select()
        .eq('is_active', true)
        .order('nama');
    listBankSampah.value =
        (data as List).map((e) => BankSampahModel.fromJson(e)).toList();
  }

  Future<List<String>> getBankSampahPengelola(String profileId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaBankSampah)
        .select('bank_sampah_id')
        .eq('profile_id', profileId);
    return (data as List).map((e) => e['bank_sampah_id'] as String).toList();
  }

  void goToForm() => Get.toNamed(AppRoutes.formPengelola);

  Future<void> tambahPengelola() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      // 1. Buat akun auth
      final response = await SupabaseService.client.auth.admin.createUser(
        AdminUserAttributes(
          email: emailController.text.trim(),
          password: passwordController.text,
          emailConfirm: true,
        ),
      );

      if (response.user == null) {
        Get.snackbar('Gagal', 'Gagal membuat akun pengelola.');
        return;
      }

      // 2. Insert profile
      final profileData = await SupabaseService.client
          .from(SupabaseConstants.tableProfiles)
          .insert({
        'auth_user_id': response.user!.id,
        'nama_lengkap': namaController.text.trim(),
        'no_hp': noHpController.text.trim().isEmpty
            ? null
            : noHpController.text.trim(),
        'role': 'pengelola',
      }).select().single();

      final profileId = profileData['id'] as String;

      // 3. Hubungkan ke bank sampah yang dipilih
      if (selectedBankSampahIds.isNotEmpty) {
        final relasi = selectedBankSampahIds
            .map((bsId) => {
                  'profile_id': profileId,
                  'bank_sampah_id': bsId,
                })
            .toList();
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaBankSampah)
            .insert(relasi);
      }

      await _fetchPengelola();
      Get.back();
      Get.snackbar('Berhasil', 'Akun pengelola berhasil dibuat.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal membuat akun pengelola.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateRelasiPengelola(
      String profileId, List<String> bankSampahIds) async {
    try {
      // Hapus semua relasi lama
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaBankSampah)
          .delete()
          .eq('profile_id', profileId);

      // Insert relasi baru
      if (bankSampahIds.isNotEmpty) {
        final relasi = bankSampahIds
            .map((bsId) => {
                  'profile_id': profileId,
                  'bank_sampah_id': bsId,
                })
            .toList();
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaBankSampah)
            .insert(relasi);
      }

      Get.snackbar('Berhasil', 'Relasi bank sampah diperbarui.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memperbarui relasi.');
    }
  }

  Future<void> hapusPengelola(String profileId) async {
    try {
      // Hapus profile (cascade hapus relasi)
      await SupabaseService.client
          .from(SupabaseConstants.tableProfiles)
          .delete()
          .eq('id', profileId);
      listPengelola.removeWhere((e) => e.id == profileId);
      Get.snackbar('Berhasil', 'Pengelola berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', 'Pengelola gagal dihapus.');
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    noHpController.dispose();
    super.onClose();
  }
}
