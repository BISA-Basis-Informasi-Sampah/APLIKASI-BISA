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

  // Alias getter agar cocok dengan nama yang dipakai di view
  int get jumlahBankAktif => totalBankSampahAktif.value;
  double get totalSampahBulanIni => totalJumlahBulanIni.value;

  // Bank sampah aktif — untuk section aktivitas terbaru
  final bankSampahAktif = <BankSampahModel>[].obs;

  // Aktivitas terbaru — list Map untuk ditampilkan di dashboard
  final aktivitasTerbaru = <Map<String, dynamic>>[].obs;

  String get penggunaNama =>
      SessionService.to.profile.value?.namaLengkap ?? '-';

  // FIX: namaKelurahan tidak lagi sama dengan namaLengkap pengguna.
  // Jika ingin nama kelurahan yang sesungguhnya, tambahkan kolom
  // nama_kelurahan di tabel profiles dan ambil dari sana.
  String get namaKelurahan => 'Kelurahan';

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
        _fetchAktivitasTerbaru(),
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

    final list =
        (data as List).map((e) => BankSampahModel.fromJson(e)).toList();
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
        .gte('tanggal_pengelolaan',
            firstDay.toIso8601String().split('T').first)
        .lte('tanggal_pengelolaan',
            lastDay.toIso8601String().split('T').first);

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

  Future<void> _fetchAktivitasTerbaru() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('''
          jumlah,
          total_harga,
          tanggal_pengelolaan,
          bank_sampah(nama),
          jenis_sampah(nama),
          satuan(singkatan)
        ''')
        .gte('tanggal_pengelolaan',
            firstDay.toIso8601String().split('T').first)
        .lte('tanggal_pengelolaan',
            lastDay.toIso8601String().split('T').first)
        .order('tanggal_pengelolaan', ascending: false)
        .limit(10);

    aktivitasTerbaru.value = (data as List).map((e) {
      return {
        'bank_nama': (e['bank_sampah'] as Map?)?['nama'] ?? '-',
        'jenis_nama': (e['jenis_sampah'] as Map?)?['nama'] ?? '-',
        'jumlah': e['jumlah'],
        'total_harga': e['total_harga'],
        'satuan_singkatan': (e['satuan'] as Map?)?['singkatan'] ?? '',
        'tanggal': e['tanggal_pengelolaan'],
      };
    }).toList();
  }

  // Navigasi
  void goToMonitoring() => Get.toNamed(AppRoutes.monitoringBankSampah);
  void goToManajemenBankSampah() =>
      Get.toNamed(AppRoutes.manajemenBankSampah);
  void goToMasterSampah() => Get.toNamed(AppRoutes.masterSampah);
  void goToManajemenPengelola() =>
      Get.toNamed(AppRoutes.manajemenPengelola);
  void goToLaporan() => Get.toNamed(AppRoutes.generatorLaporan);
  void goToProfil() => Get.toNamed(AppRoutes.profilKelurahan);
  void goToDetailBankSampah(BankSampahModel b) =>
      Get.toNamed(AppRoutes.detailBankSampah, arguments: b);

  Future<void> refresh() => fetchDashboardData();
}