import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_notifier.dart';
import 'providers/package_notifier.dart';
import 'screens/splash_screen.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: SupabaseConfig.debugMode,
    );
    debugPrint('✅ Supabase initialisé avec succès');
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'initialisation Supabase: $e');
    debugPrint('⚠️  Vérifiez vos credentials dans lib/config/supabase_config.dart');
    // L'application continue même si Supabase échoue (pour le développement)
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProxyProvider<AuthNotifier, PackageNotifier>(
          create: (context) => PackageNotifier(Provider.of<AuthNotifier>(context, listen: false)),
          update: (context, authNotifier, previous) => previous ?? PackageNotifier(authNotifier),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Delivery Gabon',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(), // Affiche le splash screen en premier
      ),
    );
  }
}
