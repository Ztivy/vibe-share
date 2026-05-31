import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vibe_share/screens/login_screen.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

// ── Datos de cada slide ───────────────────────────────────────────────────────

class _SlideData {
  final String title;
  final String body;
  final IconData icon;
  final Color gradientTop;
  final Color gradientBottom;
  final List<_FloatingNote> notes;

  const _SlideData({
    required this.title,
    required this.body,
    required this.icon,
    required this.gradientTop,
    required this.gradientBottom,
    required this.notes,
  });
}

class _FloatingNote {
  final String emoji;
  final double left;   // porcentaje del ancho
  final double top;    // porcentaje del alto
  final double size;
  final Duration delay;

  const _FloatingNote({
    required this.emoji,
    required this.left,
    required this.top,
    required this.size,
    required this.delay,
  });
}

const _slides = [
  _SlideData(
    title: StringsApp.onboarding1Title,
    body: StringsApp.onboarding1Body,
    icon: Icons.music_note_rounded,
    gradientTop: Color(0xFF6C63FF),
    gradientBottom: Color(0xFF9B8FFF),
    notes: [
      _FloatingNote(emoji: '🎵', left: 0.12, top: 0.18, size: 36, delay: Duration(milliseconds: 0)),
      _FloatingNote(emoji: '🎸', left: 0.75, top: 0.12, size: 44, delay: Duration(milliseconds: 400)),
      _FloatingNote(emoji: '🎧', left: 0.60, top: 0.55, size: 32, delay: Duration(milliseconds: 200)),
      _FloatingNote(emoji: '🎤', left: 0.08, top: 0.65, size: 28, delay: Duration(milliseconds: 600)),
      _FloatingNote(emoji: '🎹', left: 0.80, top: 0.72, size: 38, delay: Duration(milliseconds: 300)),
    ],
  ),
  _SlideData(
    title: StringsApp.onboarding2Title,
    body: StringsApp.onboarding2Body,
    icon: Icons.people_rounded,
    gradientTop: Color(0xFFFF6B6B),
    gradientBottom: Color(0xFFFF9A9A),
    notes: [
      _FloatingNote(emoji: '🤝', left: 0.10, top: 0.15, size: 40, delay: Duration(milliseconds: 100)),
      _FloatingNote(emoji: '❤️', left: 0.78, top: 0.20, size: 30, delay: Duration(milliseconds: 500)),
      _FloatingNote(emoji: '🎶', left: 0.65, top: 0.58, size: 36, delay: Duration(milliseconds: 0)),
      _FloatingNote(emoji: '✨', left: 0.15, top: 0.70, size: 28, delay: Duration(milliseconds: 350)),
      _FloatingNote(emoji: '🫂', left: 0.82, top: 0.68, size: 34, delay: Duration(milliseconds: 250)),
    ],
  ),
  _SlideData(
    title: StringsApp.onboarding3Title,
    body: StringsApp.onboarding3Body,
    icon: Icons.electric_bolt_rounded,
    gradientTop: Color(0xFF06D6A0),
    gradientBottom: Color(0xFF4ECDC4),
    notes: [
      _FloatingNote(emoji: '🔥', left: 0.08, top: 0.14, size: 38, delay: Duration(milliseconds: 200)),
      _FloatingNote(emoji: '🎯', left: 0.76, top: 0.18, size: 32, delay: Duration(milliseconds: 0)),
      _FloatingNote(emoji: '📻', left: 0.68, top: 0.60, size: 40, delay: Duration(milliseconds: 450)),
      _FloatingNote(emoji: '💫', left: 0.10, top: 0.68, size: 26, delay: Duration(milliseconds: 300)),
      _FloatingNote(emoji: '🎼', left: 0.84, top: 0.72, size: 34, delay: Duration(milliseconds: 150)),
    ],
  ),
];

// ── OnboardingScreen ──────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StringsApp.prefOnboardingDone, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: a,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── PageView ────────────────────────────────────────────────────
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _SlidePage(data: _slides[i], index: i),
          ),

          // ── Botón Saltar (top-right) ─────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(ThemeApp.spacingMd),
                child: AnimatedOpacity(
                  opacity: _currentPage < _slides.length - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: TextButton(
                    onPressed: _currentPage < _slides.length - 1
                        ? _finishOnboarding
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeApp.spacingMd,
                        vertical: ThemeApp.spacingSm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeApp.radiusFull),
                      ),
                    ),
                    child: Text(
                      StringsApp.onboardingSkip,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom controls ──────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: _slides.length,
              controller: _controller,
              onNext: _nextPage,
              activeColor: _slides[_currentPage].gradientTop,
            ),
          ),
        ],
      ),
    );
  }
}

// ── _SlidePage ────────────────────────────────────────────────────────────────

class _SlidePage extends StatefulWidget {
  final _SlideData data;
  final int index;

  const _SlidePage({required this.data, required this.index});

  @override
  State<_SlidePage> createState() => _SlidePageState();
}

class _SlidePageState extends State<_SlidePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final d = widget.data;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [d.gradientTop, d.gradientBottom],
        ),
      ),
      child: Stack(
        children: [
          // ── Emojis flotantes ────────────────────────────────────────
          ...d.notes.map((note) => _FloatingEmoji(note: note, size: size)),

          // ── Contenido central ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeApp.spacingXl,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Ícono principal con anillo
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _CenterIcon(icon: d.icon),
                    ),
                  ),

                  const SizedBox(height: ThemeApp.spacingXl),

                  // Título
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Text(
                        d.title,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: Colors.white,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: ThemeApp.spacingMd),

                  // Cuerpo
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Text(
                        d.body,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _CenterIcon ───────────────────────────────────────────────────────────────

class _CenterIcon extends StatelessWidget {
  final IconData icon;
  const _CenterIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white12,
        border: Border.all(color: Colors.white30, width: 2),
      ),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
          ),
          child: Icon(icon, size: 52, color: Colors.white),
        ),
      ),
    );
  }
}

// ── _FloatingEmoji ────────────────────────────────────────────────────────────

class _FloatingEmoji extends StatefulWidget {
  final _FloatingNote note;
  final Size size;
  const _FloatingEmoji({required this.note, required this.size});

  @override
  State<_FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<_FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _float = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.note.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.note;
    final s = widget.size;

    return Positioned(
      left: s.width * n.left,
      top: s.height * n.top,
      child: AnimatedBuilder(
        animation: _float,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, -10 * _float.value),
          child: Opacity(
            opacity: 0.55 + 0.3 * _float.value,
            child: Text(n.emoji, style: TextStyle(fontSize: n.size)),
          ),
        ),
      ),
    );
  }
}

// ── _BottomControls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageController controller;
  final VoidCallback onNext;
  final Color activeColor;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.controller,
    required this.onNext,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;

    return Container(
      padding: EdgeInsets.only(
        left: ThemeApp.spacingXl,
        right: ThemeApp.spacingXl,
        bottom: MediaQuery.of(context).padding.bottom + ThemeApp.spacingXl,
        top: ThemeApp.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de páginas
          SmoothPageIndicator(
            controller: controller,
            count: totalPages,
            effect: WormEffect(
              dotWidth: 10,
              dotHeight: 10,
              spacing: 10,
              activeDotColor: Colors.white,
              dotColor: Colors.white38,
              type: WormType.thin,
            ),
          ),

          const SizedBox(height: ThemeApp.spacingXl),

          // Botón
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                  onTap: onNext,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        isLast
                            ? StringsApp.onboardingGetStarted
                            : StringsApp.onboardingNext,
                        key: ValueKey(isLast),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: activeColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
