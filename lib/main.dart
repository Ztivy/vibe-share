import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vibe_share/firebase_options.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/providers/publicaciones_provider.dart';
import 'package:vibe_share/screens/dashboard_screen.dart';
import 'package:vibe_share/screens/login_screen.dart';
import 'package:vibe_share/screens/onboarding_screen.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

// ── Supabase — reemplaza con tus credenciales reales ─────────────────────────
const _supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const _supabaseAnonKey = 'YOUR_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Leer SharedPreferences para saber si ya se vio el onboarding
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(StringsApp.prefOnboardingDone) ?? false;

  runApp(MyApp(onboardingDone: onboardingDone));
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;
  const MyApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PublicacionesProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: StringsApp.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeApp.light,
            darkTheme: ThemeApp.dark,
            themeMode: auth.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: _resolveHome(auth),
          );
        },
      ),
    );
  }

  Widget _resolveHome(AuthProvider auth) {
    if (auth.isAuthenticated) return const DashboardScreen();
    if (!onboardingDone) return const OnboardingScreen();
    //return const LoginScreen();
    return const DashboardScreen();
  }
}