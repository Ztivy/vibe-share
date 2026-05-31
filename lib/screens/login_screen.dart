import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginConGoogle();

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? StringsApp.loginError),
          backgroundColor: AppColors.error,
        ),
      );
    }
    // Si ok == true, main.dart redirige automáticamente al Dashboard
    // gracias al Consumer<AuthProvider> en MaterialApp
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo degradado + formas decorativas ──────────────────────
          _Background(size: size),

          // ── Contenido ──────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeApp.spacingXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo + nombre
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: const _LogoSection(),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Título y subtítulo
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: const _TextSection(),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Botón Google
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _GoogleButton(onTap: () => _handleGoogleLogin(context)),
                    ),
                  ),

                  const SizedBox(height: ThemeApp.spacingMd),

                  // Términos
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: const _TermsText(),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _Background ───────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  final Size size;
  const _Background({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Fondo base oscuro
          Container(color: AppColors.backgroundDark),

          // Blob superior-izquierdo
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.55),
                    AppColors.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Blob inferior-derecho
          Positioned(
            bottom: -size.height * 0.08,
            right: -size.width * 0.15,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.40),
                    AppColors.accent.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Blob central-derecho pequeño (toque de dorado)
          Positioned(
            top: size.height * 0.38,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.45,
              height: size.width * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentGold.withOpacity(0.25),
                    AppColors.accentGold.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _LogoSection ──────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícono con efecto de brillo
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF9B8FFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note_rounded,
            size: 52,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: ThemeApp.spacingMd),

        // Nombre de la app
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFD4D0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            StringsApp.appName,
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── _TextSection ──────────────────────────────────────────────────────────────

class _TextSection extends StatelessWidget {
  const _TextSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          StringsApp.loginTitle,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ThemeApp.spacingSm),
        Text(
          StringsApp.loginSubtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondaryDark,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── _GoogleButton ─────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SizedBox(
          width: double.infinity,
          height: 58,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: auth.isLoading ? null : onTap,
              borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: auth.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ícono Google (SVG simplificado con texto G)
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const _GoogleLogo(),
                            ),
                            const SizedBox(width: ThemeApp.spacingMd),
                            Text(
                              StringsApp.loginGoogle,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── _GoogleLogo ───────────────────────────────────────────────────────────────
// Logo de Google hecho con CustomPaint para no depender de un asset

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Azul
    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    // Rojo
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    // Amarillo
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    // Verde
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    // Cuadrantes simplificados
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.5, 1.6, true, paintBlue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.1, 1.6, true, paintGreen,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.7, 1.6, true, paintYellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -2.1, 1.6, true, paintRed,
    );

    // Centro blanco para el "G"
    canvas.drawCircle(Offset(cx, cy), r * 0.55, Paint()..color = Colors.white);

    // Barra horizontal del G
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.12, r * 0.85, r * 0.24),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── _TermsText ────────────────────────────────────────────────────────────────

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Al continuar, aceptas nuestros Términos de uso\ny Política de privacidad',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondaryDark,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
