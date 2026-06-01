import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:vibe_share/firebase/notificaciones_firestore.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/screens/feed_screen.dart';
import 'package:vibe_share/screens/nueva_publicacion_screen.dart';
import 'package:vibe_share/screens/perfil_screen.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';
import 'package:vibe_share/screens/amigos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    _DiscoverPlaceholder(),
    NuevaPublicacionScreen(),
    const AmigosScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeApp.spacingMd,
              vertical: ThemeApp.spacingSm,
            ),
            child: SalomonBottomBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              selectedItemColor: AppColors.primary,
              unselectedItemColor:
                  isDark ? AppColors.textSecondaryDark : AppColors.textHint,
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_rounded),
                  title: Text(StringsApp.navFeed),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.explore_rounded),
                  title: Text(StringsApp.navDiscover),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.add_circle_rounded),
                  title: Text(StringsApp.navPublish),
                  selectedColor: AppColors.accent,
                ),
                SalomonBottomBarItem(
                  icon: const _FriendsIconBadge(),
                  title: Text(StringsApp.navFriends),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_rounded),
                  title: Text(StringsApp.navProfile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoverPlaceholder extends StatelessWidget {
  const _DiscoverPlaceholder();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Descubrir — C7')),
      );
}

class _FriendsIconBadge extends StatelessWidget {
  const _FriendsIconBadge();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.usuarioActual?.uid;

    if (uid == null) {
      return const Icon(Icons.people_rounded);
    }

    return StreamBuilder<int>(
      stream: NotificacionesFirestore().streamNoLeidas(uid),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.people_rounded),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FriendsPlaceholder extends StatelessWidget {
  const _FriendsPlaceholder();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Amigos — C7')),
      );
}