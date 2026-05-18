import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/pengelolaan_sampah_model.dart';
import '../../app/routes/app_routes.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final aktivitasTerbaru = <PengelolaanSampahModel>[].obs;

  // Statistik
  final totalJumlahBulanIni = 0.0.obs;
  final totalTransaksiBulanIni = 0.obs;
  final totalNilaiBulanIni = 0.0.obs;

  String get bankSampahNama => SessionService.to.activeBankSampahNama;
  String get penggunaNama =>
      SessionService.to.profile.value?.namaLengkap ?? '-';

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchAktivitasTerbaru(),
        _fetchStatistikBulanIni(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data dashboard.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAktivitasTerbaru() async {
    final bankSampahId = SessionService.to.activeBankSampahId;

    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('''
          *,
          kategori_sampah(*),
          sub_kategori_sampah(*),
          jenis_sampah(*),
          satuan(*)
        ''')
        .eq('bank_sampah_id', bankSampahId)
        .order('tanggal_pengelolaan', ascending: false)
        .limit(5);

    aktivitasTerbaru.value = (data as List)
        .map((e) => PengelolaanSampahModel.fromJson(e))
        .toList();
  }

  Future<void> _fetchStatistikBulanIni() async {
    final bankSampahId = SessionService.to.activeBankSampahId;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('jumlah, total_harga')
        .eq('bank_sampah_id', bankSampahId)
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

  void goToInputSampah() => Get.toNamed(AppRoutes.inputSampah);
  void goToHistori() => Get.toNamed(AppRoutes.historiSampah);
  void goToHarga() => Get.toNamed(AppRoutes.hargaSampah);
  void goToProfil() => Get.toNamed(AppRoutes.profilBankSampah);
  void goToPilihBankSampah() => Get.toNamed(AppRoutes.pilihBankSampah);

  Future<void> refresh() => fetchDashboardData();
}
