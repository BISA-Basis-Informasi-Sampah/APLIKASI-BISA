import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../core/services/session_service.dart';
import '../core/constants/supabase_constants.dart';
import '../models/profile_model.dart';
import '../app/routes/app_routes.dart';

class AuthController extends GetxController {
  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // Text controllers — login
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Text controllers — register
  final regNamaController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  final regNoHpController = TextEditingController();

  // State
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  // ─── Login ──────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user == null) {
        _showError('Login gagal. Periksa email dan password kamu.');
        return;
      }

      await _loadProfileAndNavigate(response.user!.id);
    } on AuthException catch (e) {
      _showError(_mapAuthError(e.message));
    } catch (e) {
      _showError('Gagal terhubung ke server. Periksa koneksi internet kamu.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Register ────────────────────────────────────────────────────────────────
  Future<void> register() async {
  if (!registerFormKey.currentState!.validate()) return;
 
  isLoading.value = true;
  try {
    final response = await SupabaseService.client.auth.signUp(
      email: regEmailController.text.trim(),
      password: regPasswordController.text,
    );
 
    if (response.user == null) {
      _showError('Registrasi gagal. Coba lagi.');
      return;
    }
 
    try {
      // Insert profil — jika gagal, hapus akun auth yang baru dibuat
      await SupabaseService.client
          .from(SupabaseConstants.tableProfiles)
          .insert({
            'auth_user_id': response.user!.id,
            'nama_lengkap': regNamaController.text.trim(),
            'no_hp': regNoHpController.text.trim().isEmpty
                ? null
                : regNoHpController.text.trim(),
            'role': 'pengelola',
          });
    } catch (profileError) {
      // Rollback: hapus akun auth karena profil gagal dibuat
      // Ini butuh Edge Function atau signOut agar tidak ada akun
      // auth tanpa profil
      await SupabaseService.client.auth.signOut();
      _showError('Registrasi gagal. Silakan coba lagi.');
      return;
    }
 
    await _loadProfileAndNavigate(response.user!.id);
  } on AuthException catch (e) {
    _showError(_mapAuthError(e.message));
  } catch (e) {
    _showError('Registrasi gagal. Periksa koneksi internet kamu.');
  } finally {
    isLoading.value = false;
  }
}

  // ─── Logout ──────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await SupabaseService.client.auth.signOut();
      SessionService.to.clearSession();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _showError('Gagal logout. Coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Load profile & navigasi sesuai role ─────────────────────────────────────
  Future<void> _loadProfileAndNavigate(String authUserId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableProfiles)
        .select()
        .eq('auth_user_id', authUserId)
        .single();

    final profile = ProfileModel.fromJson(data);
    SessionService.to.setProfile(profile);

    if (profile.isKelurahan) {
      Get.offAllNamed(AppRoutes.dashboardKelurahan);
    } else {
      Get.offAllNamed(AppRoutes.pilihBankSampah);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────
  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi. Periksa inbox kamu.';
    }
    if (message.contains('User already registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }

  void _showError(String message) {
    Get.snackbar(
      'Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);
  void goToLogin() => Get.back();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    regNamaController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    regConfirmPasswordController.dispose();
    regNoHpController.dispose();
    super.onClose();
  }
}
