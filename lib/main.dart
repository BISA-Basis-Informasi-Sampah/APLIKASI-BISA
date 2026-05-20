import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'core/services/session_service.dart';
import 'models/profile_model.dart';
import 'controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await dotenv.load(fileName: ".env");

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-key';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  await Get.putAsync(() async => SessionService());
  Get.put(AuthController(), permanent: true);

  // Cek existing session Supabase (persist setelah browser refresh)
  final existingUser = Supabase.instance.client.auth.currentUser;
  String initialRoute = AppRoutes.login;

  if (existingUser != null) {
    try {
      final data = await Supabase.instance.client
          .from(SupabaseConstants.tableProfiles)
          .select()
          .eq('auth_user_id', existingUser.id)
          .single();

      final profile = ProfileModel.fromJson(data);
      SessionService.to.setProfile(profile);

      if (profile.isKelurahan) {
        initialRoute = AppRoutes.dashboardKelurahan;
      } else if (!profile.isVerified) {
        initialRoute = AppRoutes.menungguVerifikasi;
      } else {
        // Pengelola: arahkan ke pilihBankSampah agar bisa pilih BSU aktif
        initialRoute = AppRoutes.pilihBankSampah;
      }
    } catch (_) {
      // Jika gagal restore profile, kembali ke login
      initialRoute = AppRoutes.login;
    }
  }

  runApp(BisaApp(initialRoute: initialRoute));
}

class BisaApp extends StatelessWidget {
  final String initialRoute;
  const BisaApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BISA - Bank Informasi Sampah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}