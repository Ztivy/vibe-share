import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vibe_share/firebase_options.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/providers/publicaciones_provider.dart';
import 'package:vibe_share/screens/dashboard_screen.dart';
import 'package:vibe_share/screens/login_screen.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

// ── Supabase — reemplaza con tus credenciales reales ─────────────────────────
const _supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const _supabaseAnonKey = 'YOUR_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo portrait
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

  runApp(const VibeShareApp());
}

class VibeShareApp extends StatelessWidget {
  const VibeShareApp({super.key});

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
            home: auth.isLoading
                ? const _SplashScreen()
                : auth.isAuthenticated
                    ? const DashboardScreen()
                    : const LoginScreen(),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note_rounded,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              StringsApp.appName,
              style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              StringsApp.appTagline,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
