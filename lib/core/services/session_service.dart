import 'package:get/get.dart';
import '../../models/profile_model.dart';
import '../../models/bank_sampah_model.dart';

class SessionService extends GetxService {
  static SessionService get to => Get.find();

  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final Rx<BankSampahModel?> activeBankSampah = Rx<BankSampahModel?>(null);

  bool get isKelurahan => profile.value?.role == 'kelurahan';
  bool get isPengelola => profile.value?.role == 'pengelola';

  String? get activeBankSampahIdOrNull => activeBankSampah.value?.id;
  String get activeBankSampahId => activeBankSampah.value?.id ?? '';
  String get activeBankSampahNama => activeBankSampah.value?.nama ?? '';

  void setProfile(ProfileModel p) => profile.value = p;

  void setActiveBankSampah(BankSampahModel b) => activeBankSampah.value = b;

  void clearSession() {
    profile.value = null;
    activeBankSampah.value = null;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
  }
}