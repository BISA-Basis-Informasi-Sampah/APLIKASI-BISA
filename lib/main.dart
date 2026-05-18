import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-key';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const BisaApp());
}

class BisaApp extends StatelessWidget {
  const BisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BISA - Bank Informasi Sampah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
