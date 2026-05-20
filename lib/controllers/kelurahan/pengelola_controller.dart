import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final isApprovingId = ''.obs;
  final isPasswordVisible = false.obs;

  // ── State untuk sheet approve ────────────────────────────────────────────────
  // Menyimpan pilihan bank sampah sementara saat sheet approve dibuka.
  // Dipakai oleh sheet agar Obx bisa reaktif dengan benar.
  final approveSelectedIds = <String>[].obs;

  void togglePassword() => isPasswordVisible.value = !isPasswordVisible.value;

  void resetForm() {
    formKey.currentState?.reset();
    namaController.clear();
    emailController.clear();
    passwordController.clear();
    noHpController.clear();
    selectedBankSampahIds.clear();
  }

  /// Siapkan state pilihan bank sampah untuk sheet approve.
  /// Harus dipanggil sebelum membuka sheet approve.
  void initApproveSheet(ProfileModel pengelola) {
    // Pre-select pilihan bank sampah dari registrasi
    approveSelectedIds.value = List<String>.from(pengelola.bankSampahPilihan);
  }

  void toggleApproveBank(String bankId, bool selected) {
    if (selected) {
      if (!approveSelectedIds.contains(bankId)) {
        approveSelectedIds.add(bankId);
      }
    } else {
      approveSelectedIds.remove(bankId);
    }
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
    listPengelola.value = semua.where((p) => p.isVerified).toList();
    listPending.value = semua.where((p) => !p.isVerified).toList();
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

  // ─── Approve pengelola yang daftar mandiri ────────────────────────────────────
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

      // 4. Update list lokal
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchPengelola();
      });

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

      bool deletedViaFunction = false;
      try {
        final response = await SupabaseService.client.functions.invoke(
          'delete-pengelola',
          body: {'auth_user_id': authUserId, 'profile_id': profileId},
        );

        if (response.status == 200) {
          deletedViaFunction = true;
        } else {
          final errorMsg = (response.data is Map)
              ? (response.data['error'] ?? response.data['message'])
              : response.data?.toString();
          debugPrint('Edge Function tolak gagal: ${errorMsg ?? response.status}');
        }
      } catch (e) {
        debugPrint('Edge Function tolak error: $e');
      }

      // Fallback: Hapus langsung dari database jika Edge Function gagal
      if (!deletedViaFunction) {
        // Hapus relasi jika ada (opsional tapi aman)
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaBankSampah)
            .delete()
            .eq('profile_id', profileId);

        // Hapus profile
        await SupabaseService.client
            .from(SupabaseConstants.tableProfiles)
            .delete()
            .eq('id', profileId);
      }

      listPending.removeWhere((e) => e.id == profileId);
      Get.snackbar(
        'Ditolak',
        deletedViaFunction
            ? 'Pendaftaran pengelola telah ditolak.'
            : 'Pendaftaran ditolak (dibersihkan via database).',
      );
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menolak pendaftaran: ${e.toString()}');
    } finally {
      isApprovingId.value = '';
    }
  }

  // ─── Tambah pengelola oleh kelurahan ─────────────────────────────────────────
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
      await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaBankSampah)
          .delete()
          .eq('profile_id', profileId);

      if (bankSampahIds.isNotEmpty) {
        final relasi = bankSampahIds
            .map((bsId) => {'profile_id': profileId, 'bank_sampah_id': bsId})
            .toList();
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaBankSampah)
            .insert(relasi);

        await SupabaseService.client
            .from(SupabaseConstants.tableProfiles)
            .update({'is_verified': true})
            .eq('id', profileId);
      } else {
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

      bool deletedViaFunction = false;
      try {
        final response = await SupabaseService.client.functions.invoke(
          'delete-pengelola',
          body: {'auth_user_id': authUserId, 'profile_id': profileId},
        );

        if (response.status == 200) {
          deletedViaFunction = true;
        } else {
          final errorMsg = (response.data is Map)
              ? (response.data['error'] ?? response.data['message'])
              : response.data?.toString();
          debugPrint('Edge Function hapus gagal: ${errorMsg ?? response.status}');
        }
      } catch (e) {
        debugPrint('Edge Function hapus error: $e');
      }

      // Fallback: Hapus langsung dari database jika Edge Function gagal
      if (!deletedViaFunction) {
        // Hapus relasi di pengelola_bank_sampah
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaBankSampah)
            .delete()
            .eq('profile_id', profileId);

        // Hapus profile
        await SupabaseService.client
            .from(SupabaseConstants.tableProfiles)
            .delete()
            .eq('id', profileId);
      }

      listPengelola.removeWhere((e) => e.id == profileId);
      Get.snackbar(
        'Berhasil',
        deletedViaFunction
            ? 'Pengelola berhasil dihapus.'
            : 'Pengelola dihapus (dibersihkan via database).',
      );
    } catch (e) {
      Get.snackbar('Gagal', 'Pengelola gagal dihapus: ${e.toString()}');
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