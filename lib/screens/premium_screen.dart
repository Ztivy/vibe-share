import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_share/firebase/stripe_service.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _stripe = StripeService();
  bool _loading = false;

  Future<void> _suscribirse() async {
    setState(() => _loading = true);
    final ok = await _stripe.iniciarPago();
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      await context.read<AuthProvider>().refrescarUsuario();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido a VibeShare Premium! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago cancelado.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().usuarioActual;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user?.esPremium == true) {
      return _YaEsPremiumScreen();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD166), Color(0xFFFF9A3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, size: 56, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'VibeShare Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Sin anuncios. Sin límites.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(ThemeApp.spacingLg),
              child: Column(
                children: [
                  // Precio
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeApp.spacingMd,
                      horizontal: ThemeApp.spacingXl,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                      border: Border.all(color: AppColors.accentGold),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: '\$59',
                            style: TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' MXN / mes',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: ThemeApp.spacingXl),

                  // Beneficios
                  ...StringsApp.premiumBenefits.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: ThemeApp.spacingMd),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: AppColors.success, size: 18),
                        ),
                        const SizedBox(width: ThemeApp.spacingMd),
                        Expanded(
                          child: Text(b,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: ThemeApp.spacingMd),

                  // Banner anuncio actual (lo que desaparece)
                  AdBanner(isDark: isDark),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Con Premium nunca más verás esto ↑',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: ThemeApp.spacingXl),

                  // Botón CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _suscribirse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Suscribirme — \$59 MXN/mes',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),

                  const SizedBox(height: ThemeApp.spacingMd),

                  Text(
                    'Pago seguro con Stripe\nUsa 4242 4242 4242 4242 para probar',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: ThemeApp.spacingXxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YaEsPremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeApp.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  size: 80, color: AppColors.accentGold),
              const SizedBox(height: ThemeApp.spacingMd),
              Text('¡Ya eres Premium!',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: ThemeApp.spacingSm),
              Text(
                'Estás disfrutando de todos los beneficios.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget público reutilizable en feed ───────────────────────────────────────

class AdBanner extends StatelessWidget {
  final bool isDark;
  const AdBanner({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeApp.spacingMd,
        vertical: ThemeApp.spacingSm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('AD',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textHint)),
          ),
          const SizedBox(width: ThemeApp.spacingMd),
          Expanded(
            child: Text(
              'Esto es un anuncio',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          Icon(Icons.close_rounded, size: 16, color: AppColors.textHint),
        ],
      ),
    );
  }
}