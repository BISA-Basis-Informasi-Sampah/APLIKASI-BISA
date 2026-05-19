class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Pilih bank sampah (pengelola setelah login)
  static const String pilihBankSampah = '/pilih-bank-sampah';

  // Pengelola
  static const String dashboardPengelola = '/pengelola/dashboard';
  static const String inputSampah = '/pengelola/input-sampah';
  // editSampah DIHAPUS — edit dilakukan via inputSampah dengan arguments
  static const String historiSampah = '/pengelola/histori';
  static const String hargaSampah = '/pengelola/harga';
  static const String profilBankSampah = '/pengelola/profil';

  // Kelurahan
  static const String dashboardKelurahan = '/kelurahan/dashboard';
  static const String monitoringBankSampah = '/kelurahan/monitoring';
  static const String detailBankSampah = '/kelurahan/bank-sampah/detail';
  static const String manajemenBankSampah = '/kelurahan/bank-sampah';
  static const String formBankSampah = '/kelurahan/bank-sampah/form';
  static const String masterSampah = '/kelurahan/master-sampah';
  static const String manajemenPengelola = '/kelurahan/pengelola';
  static const String formPengelola = '/kelurahan/pengelola/form';
  static const String generatorLaporan = '/kelurahan/laporan';
  static const String profilKelurahan = '/kelurahan/profil';
}