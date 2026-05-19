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

  // Pengelola aktif (sudah verified)
  final listPengelola = <ProfileModel>[].obs;
  // Pengelola pending (belum verified, daftar mandiri)
  final listPending = <ProfileModel>[].obs;

  final listBankSampah = <BankSampahModel>[].obs;
  final selectedBankSampahIds = <String>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isApprovingId = ''.obs; // id profil yang sedang diproses approve
  final isPasswordVisible = false.obs;

  void togglePassword() => isPasswordVisible.value = !isPasswordVisible.value;

  void resetForm() {
    formKey.currentState?.reset();
    namaController.clear();
    emailController.clear();
    passwordController.clear();
    noHpController.clear();
    selectedBankSampahIds.clear();
  }

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

    final semua = (data as List).map((e) => ProfileModel.fromJson(e)).toList();

    // Pisahkan verified vs pending
    listPengelola.value = semua.where((p) => p.isVerified).toList();
    listPending.value = semua.where((p) => !p.isVerified).toList();
  }

  Future<void> _fetchBankSampah() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableBankSampah)
        .select()
        .eq('is_active', true)
        .order('nama');
    listBankSampah.value = (data as List)
        .map((e) => BankSampahModel.fromJson(e))
        .toList();
  }

  Future<List<String>> getBankSampahPengelola(String profileId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaBankSampah)
        .select('bank_sampah_id')
        .eq('profile_id', profileId);
    return (data as List).map((e) => e['bank_sampah_id'] as String).toList();
  }

  void goToForm() => Get.toNamed(AppRoutes.formPengelola);

  // ─── Approve pengelola yang daftar mandiri ────────────────────────────────────
  // Dipanggil setelah kelurahan memilih bank sampah yang akan di-assign.
  // Set is_verified=true + insert relasi bank sampah + kosongkan bank_sampah_pilihan.
  Future<void> approvePengelola(
    String profileId,
    List<String> bankSampahIds,
  ) async {
    if (bankSampahIds.isEmpty) {
      Get.snackbar(
        'Pilih Bank Sampah',
        'Pilih minimal satu bank sampah sebelum menyetujui.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isApprovingId.value = profileId;
    try {
      // 1. Hapus relasi lama (jika ada)
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaBankSampah)
          .delete()
          .eq('profile_id', profileId);

      // 2. Insert relasi baru
      final relasi = bankSampahIds
          .map((bsId) => {'profile_id': profileId, 'bank_sampah_id': bsId})
          .toList();
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaBankSampah)
          .insert(relasi);

      // 3. Set verified + kosongkan bank_sampah_pilihan
      await SupabaseService.client
          .from(SupabaseConstants.tableProfiles)
          .update({'is_verified': true, 'bank_sampah_pilihan': []})
          .eq('id', profileId);

      await _fetchPengelola();
      Get.snackbar('Berhasil', 'Pengelola berhasil disetujui.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menyetujui pengelola: ${e.toString()}');
    } finally {
      isApprovingId.value = '';
    }
  }

  // ─── Tolak / hapus pengelola pending ─────────────────────────────────────────
  Future<void> tolakPengelola(String profileId) async {
    isApprovingId.value = profileId;
    try {
      final profileData = await SupabaseService.client
          .from(SupabaseConstants.tableProfiles)
          .select('auth_user_id')
          .eq('id', profileId)
          .single();

      final authUserId = profileData['auth_user_id'] as String;

      final response = await SupabaseService.client.functions.invoke(
        'delete-pengelola',
        body: {'auth_user_id': authUserId, 'profile_id': profileId},
      );

      if (response.status != 200) {
        Get.snackbar('Gagal', 'Gagal menolak pendaftaran.');
        return;
      }

      listPending.removeWhere((e) => e.id == profileId);
      Get.snackbar('Ditolak', 'Pendaftaran pengelola telah ditolak.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menolak pendaftaran.');
    } finally {
      isApprovingId.value = '';
    }
  }

  // ─── Tambah pengelola oleh kelurahan (via Edge Function) ──────────────────────
  Future<void> tambahPengelola() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      final response = await SupabaseService.client.functions.invoke(
        'create-pengelola',
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'nama_lengkap': namaController.text.trim(),
          'no_hp': noHpController.text.trim().isEmpty
              ? null
              : noHpController.text.trim(),
          'bank_sampah_ids': selectedBankSampahIds.toList(),
          // is_verified: true ditangani di dalam Edge Function
        },
      );

      if (response.status != 200) {
        final msg = response.data?['error'] ?? 'Gagal membuat akun pengelola.';
        Get.snackbar('Gagal', msg);
        return;
      }

      await _fetchPengelola();
      Get.back();
      Get.snackbar('Berhasil', 'Akun pengelola berhasil dibuat.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal membuat akun pengelola: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  // ─── Update relasi bank sampah pengelola aktif ────────────────────────────────
  Future<void> updateRelasiPengelola(
    String profileId,
    List<String> bankSampahIds,
  ) async {
    isSaving.value = true;
    try {
      // 1. Hapus semua relasi lama
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaBankSampah)
          .delete()
          .eq('profile_id', profileId);

      // 2. Insert relasi baru
      if (bankSampahIds.isNotEmpty) {
        final relasi = bankSampahIds
            .map((bsId) => {'profile_id': profileId, 'bank_sampah_id': bsId})
            .toList();
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaBankSampah)
            .insert(relasi);

        // Ada bank sampah → pastikan tetap verified
        await SupabaseService.client
            .from(SupabaseConstants.tableProfiles)
            .update({'is_verified': true})
            .eq('id', profileId);
      } else {
        // Tidak ada bank sampah → cabut verifikasi
        await SupabaseService.client
            .from(SupabaseConstants.tableProfiles)
            .update({'is_verified': false})
            .eq('id', profileId);
      }

      await _fetchPengelola();
      Get.snackbar('Berhasil', 'Relasi bank sampah diperbarui.');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memperbarui relasi: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  // ─── Hapus pengelola ──────────────────────────────────────────────────────────
  Future<void> hapusPengelola(String profileId) async {
    try {
      final profileData = await SupabaseService.client
          .from(SupabaseConstants.tableProfiles)
          .select('auth_user_id')
          .eq('id', profileId)
          .single();

      final authUserId = profileData['auth_user_id'] as String;

      final response = await SupabaseService.client.functions.invoke(
        'delete-pengelola',
        body: {'auth_user_id': authUserId, 'profile_id': profileId},
      );

      if (response.status != 200) {
        Get.snackbar('Gagal', 'Pengelola gagal dihapus.');
        return;
      }

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
