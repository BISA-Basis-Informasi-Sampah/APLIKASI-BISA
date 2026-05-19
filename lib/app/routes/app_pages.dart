import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../controllers/pengelola/dashboard_controller.dart';
import '../../controllers/pengelola/input_sampah_controller.dart';
import '../../controllers/pengelola/histori_controller.dart';
import '../../controllers/pengelola/harga_controller.dart';
import '../../controllers/kelurahan/dashboard_kelurahan_controller.dart';
import '../../controllers/kelurahan/monitoring_controller.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../controllers/kelurahan/master_sampah_controller.dart';
import '../../controllers/kelurahan/pengelola_controller.dart';
import '../../controllers/kelurahan/laporan_controller.dart';

import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/auth/menunggu_verifikasi_view.dart';
import '../../views/pilih_bank_sampah/pilih_bank_sampah_view.dart';
import '../../views/pengelola/dashboard_view.dart';
import '../../views/pengelola/input_sampah_view.dart';
import '../../views/pengelola/histori_view.dart';
import '../../views/pengelola/harga_view.dart';
import '../../views/pengelola/profil_bank_sampah_view.dart';
import '../../views/kelurahan/dashboard_kelurahan_view.dart';
import '../../views/kelurahan/monitoring_view.dart';
import '../../views/kelurahan/detail_bank_sampah_view.dart';
import '../../views/kelurahan/bank_sampah_list_view.dart';
import '../../views/kelurahan/bank_sampah_form_view.dart';
import '../../views/kelurahan/master_sampah_view.dart';
import '../../views/kelurahan/pengelola_list_view.dart';
import '../../views/kelurahan/pengelola_form_view.dart';
import '../../views/kelurahan/laporan_view.dart';
import '../../views/kelurahan/profil_kelurahan_view.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    // ── Auth ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(
      name: AppRoutes.menungguVerifikasi,
      page: () => const MenungguVerifikasiView(),
      // AuthController dibutuhkan untuk fungsi logout
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),

    // ── Pilih Bank Sampah ──────────────────────────────
    GetPage(
      name: AppRoutes.pilihBankSampah,
      page: () => const PilihBankSampahView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SessionController());
      }),
    ),

    // ── Pengelola ──────────────────────────────────────
    GetPage(
      name: AppRoutes.dashboardPengelola,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.inputSampah,
      page: () => const InputSampahView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => InputSampahController());
      }),
    ),
    GetPage(
      name: AppRoutes.historiSampah,
      page: () => const HistoriView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HistoriController());
      }),
    ),
    GetPage(
      name: AppRoutes.hargaSampah,
      page: () => const HargaView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HargaController());
      }),
    ),
    GetPage(
      name: AppRoutes.profilBankSampah,
      page: () => const ProfilBankSampahView(),
    ),

    // ── Kelurahan ──────────────────────────────────────
    GetPage(
      name: AppRoutes.dashboardKelurahan,
      page: () => const DashboardKelurahanView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardKelurahanController());
      }),
    ),
    GetPage(
      name: AppRoutes.monitoringBankSampah,
      page: () => const MonitoringView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MonitoringController());
      }),
    ),
    GetPage(
      name: AppRoutes.detailBankSampah,
      page: () => const DetailBankSampahView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MonitoringController());
      }),
    ),
    GetPage(
      name: AppRoutes.manajemenBankSampah,
      page: () => const BankSampahListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BankSampahController());
      }),
    ),
    GetPage(
      name: AppRoutes.formBankSampah,
      page: () => const BankSampahFormView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BankSampahController());
      }),
    ),
    GetPage(
      name: AppRoutes.masterSampah,
      page: () => const MasterSampahView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MasterSampahController());
      }),
    ),
    GetPage(
      name: AppRoutes.manajemenPengelola,
      page: () => const PengelolaListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PengelolaController());
      }),
    ),
    GetPage(
      name: AppRoutes.formPengelola,
      page: () => const PengelolaFormView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PengelolaController());
      }),
    ),
    GetPage(
      name: AppRoutes.generatorLaporan,
      page: () => const LaporanView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LaporanController());
      }),
    ),
    GetPage(
      name: AppRoutes.profilKelurahan,
      page: () => const ProfilKelurahanView(),
    ),
  ];
}
