import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/supabase/supabase_service.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charge les variables d'environnement
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // En production Web, les vars viennent de --dart-define
  }

  // Initialise Supabase
  await SupabaseService.init();

  // Verrouille l'orientation en portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: OrivaApp()));
}

class OrivaApp extends StatelessWidget {
  const OrivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Oriva',
      debugShowCheckedModeBanner: false,
      theme: OrivaTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
