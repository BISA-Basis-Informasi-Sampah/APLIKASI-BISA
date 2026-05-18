import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/services/session_service.dart';
import '../../models/bank_sampah_model.dart';
import '../../app/routes/app_routes.dart';

class DashboardKelurahanController extends GetxController {
  final isLoading = false.obs;

  // Statistik global
  final totalBankSampah = 0.obs;
  final totalBankSampahAktif = 0.obs;
  final totalJumlahBulanIni = 0.0.obs;
  final totalTransaksiBulanIni = 0.obs;
  final totalNilaiBulanIni = 0.0.obs;

  // Bank sampah dengan aktivitas terbaru
  final bankSampahAktif = <BankSampahModel>[].obs;

  String get namaKelurahan =>
      SessionService.to.profile.value?.namaLengkap ?? 'Kelurahan';

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchStatistikBankSampah(),
        _fetchStatistikBulanIni(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data dashboard.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchStatistikBankSampah() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableBankSampah)
        .select();

    final list = (data as List)
        .map((e) => BankSampahModel.fromJson(e))
        .toList();
    totalBankSampah.value = list.length;
    totalBankSampahAktif.value = list.where((b) => b.isActive).length;
    bankSampahAktif.value = list.where((b) => b.isActive).toList();
  }

  Future<void> _fetchStatistikBulanIni() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('jumlah, total_harga')
        .gte('tanggal_pengelolaan', firstDay.toIso8601String().split('T').first)
        .lte('tanggal_pengelolaan', lastDay.toIso8601String().split('T').first);

    final list = data as List;
    totalTransaksiBulanIni.value = list.length;
    totalJumlahBulanIni.value = list.fold(
      0.0,
      (sum, e) => sum + (e['jumlah'] as num).toDouble(),
    );
    totalNilaiBulanIni.value = list.fold(
      0.0,
      (sum, e) => sum + ((e['total_harga'] as num?)?.toDouble() ?? 0.0),
    );
  }

  void goToMonitoring() => Get.toNamed(AppRoutes.monitoringBankSampah);
  void goToManajemenBankSampah() => Get.toNamed(AppRoutes.manajemenBankSampah);
  void goToMasterSampah() => Get.toNamed(AppRoutes.masterSampah);
  void goToManajemenPengelola() => Get.toNamed(AppRoutes.manajemenPengelola);
  void goToLaporan() => Get.toNamed(AppRoutes.generatorLaporan);
  void goToProfil() => Get.toNamed(AppRoutes.profilKelurahan);
  void goToDetailBankSampah(BankSampahModel b) =>
      Get.toNamed(AppRoutes.detailBankSampah, arguments: b);

  Future<void> refresh() => fetchDashboardData();
}
