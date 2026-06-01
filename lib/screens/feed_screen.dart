import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_share/models/publicacion_model.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/providers/publicaciones_provider.dart';
import 'package:vibe_share/screens/premium_screen.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';
import 'package:vibe_share/screens/dashboard_screen.dart';
import 'package:vibe_share/screens/perfil_publico_screen.dart';
import 'package:vibe_share/widgets/audio_player_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, Color(0xFF9B8FFF)],
          ).createShader(bounds),
          child: Text(
            StringsApp.feedTitle,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Amigos'),
          ],
        ),
      ),
      body: user == null
          ? const SizedBox.shrink()
          : TabBarView(
              controller: _tabController,
              children: [
                _FeedGlobal(miUid: user.uid, esPremium: user.esPremium),
                _FeedAmigos(
                  miUid: user.uid,
                  amigosUids: user.amigos,
                  esPremium: user.esPremium,
                ),
              ],
            ),
    );
  }
}

// ── Feed Global ───────────────────────────────────────────────────────────────

class _FeedGlobal extends StatelessWidget {
  final String miUid;
  final bool esPremium;
  const _FeedGlobal({required this.miUid, required this.esPremium});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicacionesProvider>();
    return StreamBuilder<List<PublicacionModel>>(
      stream: provider.feedGlobal,
      builder: (context, snap) => _FeedList(
        snap: snap,
        miUid: miUid,
        esPremium: esPremium,
        emptyMessage: StringsApp.feedEmpty,
      ),
    );
  }
}

// ── Feed Amigos ───────────────────────────────────────────────────────────────

class _FeedAmigos extends StatelessWidget {
  final String miUid;
  final List<String> amigosUids;
  final bool esPremium;
  const _FeedAmigos({
    required this.miUid,
    required this.amigosUids,
    required this.esPremium,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicacionesProvider>();
    return StreamBuilder<List<PublicacionModel>>(
      stream: provider.feedAmigos(amigosUids),
      builder: (context, snap) => _FeedList(
        snap: snap,
        miUid: miUid,
        esPremium: esPremium,
        emptyMessage:
            'Aún no tienes amigos o ellos no han publicado nada.\n¡Agrégalos en la sección Amigos!',
      ),
    );
  }
}

// ── Lista genérica ────────────────────────────────────────────────────────────

class _FeedList extends StatelessWidget {
  final AsyncSnapshot<List<PublicacionModel>> snap;
  final String miUid;
  final bool esPremium;
  final String emptyMessage;

  const _FeedList({
    required this.snap,
    required this.miUid,
    required this.esPremium,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (snap.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snap.hasError) {
      return Center(
        child: Text(
          StringsApp.errorGeneral,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final publicaciones = snap.data ?? [];

    if (publicaciones.isEmpty) {
      return _EmptyFeed(message: emptyMessage);
    }

    // Insertar un anuncio cada 4 publicaciones para usuarios no premium
    final items = <dynamic>[];
    for (var i = 0; i < publicaciones.length; i++) {
      items.add(publicaciones[i]);
      if (!esPremium && (i + 1) % 4 == 0) {
        items.add('ad'); // marcador de anuncio
      }
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: ThemeApp.spacingSm,
          bottom: ThemeApp.spacingXxl,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          if (item == 'ad') {
            return _FeedAdBanner();
          }
          return _PublicacionCard(
            publicacion: item as PublicacionModel,
            miUid: miUid,
          );
        },
      ),
    );
  }
}

// ── Banner de anuncio en el feed ──────────────────────────────────────────────

class _FeedAdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeApp.spacingMd,
        vertical: ThemeApp.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(ThemeApp.spacingMd),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PUBLICIDAD',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textHint, fontSize: 9),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.close_rounded,
                        size: 14, color: AppColors.textHint),
                  ],
                ),
                const SizedBox(height: ThemeApp.spacingMd),
                Icon(
                  Icons.campaign_rounded,
                  size: 40,
                  color: AppColors.textHint.withOpacity(0.4),
                ),
                const SizedBox(height: ThemeApp.spacingSm),
                Text(
                  'Espacio publicitario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textHint,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu anuncio podría aparecer aquí',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // CTA para quitar anuncios
          const SizedBox(height: ThemeApp.spacingXs),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
            child: Text(
              '✨ Elimina los anuncios con Premium',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: ThemeApp.spacingSm),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  final String message;
  const _EmptyFeed({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeApp.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 72,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: ThemeApp.spacingMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de publicación ────────────────────────────────────────────────────

class _PublicacionCard extends StatelessWidget {
  final PublicacionModel publicacion;
  final String miUid;

  const _PublicacionCard({
    required this.publicacion,
    required this.miUid,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tieneLike = publicacion.tieneLike(miUid);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeApp.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(publicacion: publicacion),
            const SizedBox(height: ThemeApp.spacingMd),
            _SongInfo(publicacion: publicacion, isDark: isDark),
            if (publicacion.descripcion.isNotEmpty) ...[
              const SizedBox(height: ThemeApp.spacingMd),
              Text(
                publicacion.descripcion,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (publicacion.tieneMedia) ...[
              const SizedBox(height: ThemeApp.spacingMd),
              _MediaPlayer(publicacion: publicacion, isDark: isDark),
            ],
            const SizedBox(height: ThemeApp.spacingMd),
            const Divider(height: 1),
            const SizedBox(height: ThemeApp.spacingSm),
            _CardActions(
              publicacion: publicacion,
              miUid: miUid,
              tieneLike: tieneLike,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _CardHeader ───────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final PublicacionModel publicacion;
  const _CardHeader({required this.publicacion});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _navegarAPerfil(BuildContext context) {
    final miUid = context.read<AuthProvider>().usuarioActual?.uid;
    final esMio = miUid == publicacion.autorUid;

    if (esMio) {
      final dashboard =
          context.findAncestorStateOfType<State<DashboardScreen>>();
      if (dashboard != null) {
        (dashboard as dynamic).cambiarAPerfil();
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PerfilPublicoScreen(uid: publicacion.autorUid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _navegarAPerfil(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  backgroundImage: publicacion.autorAvatarUrl.isNotEmpty
                      ? NetworkImage(publicacion.autorAvatarUrl)
                      : null,
                  child: publicacion.autorAvatarUrl.isEmpty
                      ? const Icon(Icons.person_rounded,
                          size: 22, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: ThemeApp.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        publicacion.autorNombre,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _timeAgo(publicacion.creadoEn),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (publicacion.genero.isNotEmpty)
          Chip(
            label: Text(publicacion.genero),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }
}

// ── _SongInfo ─────────────────────────────────────────────────────────────────

class _SongInfo extends StatelessWidget {
  final PublicacionModel publicacion;
  final bool isDark;
  const _SongInfo({required this.publicacion, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeApp.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
      ),
      child: Row(
        children: [
          // Album cover o ícono de música
          ClipRRect(
            borderRadius: BorderRadius.circular(ThemeApp.radiusSm),
            child: publicacion.albumCover != null &&
                    publicacion.albumCover!.isNotEmpty
                ? Image.network(
                    publicacion.albumCover!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _MusicIconSmall(),
                  )
                : _MusicIconSmall(),
          ),

          const SizedBox(width: ThemeApp.spacingMd),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publicacion.cancion,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  publicacion.artista,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (publicacion.esPremium)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeApp.spacingSm,
                vertical: ThemeApp.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
              ),
              child: const Text(
                '★ PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MusicIconSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
    );
  }
}

// ── _MediaPlayer ──────────────────────────────────────────────────────────────

class _MediaPlayer extends StatelessWidget {
  final PublicacionModel publicacion;
  final bool isDark;
  const _MediaPlayer({required this.publicacion, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (publicacion.tipoMedia == TipoMedia.video) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Video — próximamente'),
          ],
        ),
      );
    }

    // Audio con reproductor real
    return AudioPlayerWidget(
      url: publicacion.mediaUrl!,
      isDark: isDark,
    );
  }
}

// ── _CardActions ──────────────────────────────────────────────────────────────

class _CardActions extends StatelessWidget {
  final PublicacionModel publicacion;
  final String miUid;
  final bool tieneLike;

  const _CardActions({
    required this.publicacion,
    required this.miUid,
    required this.tieneLike,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicacionesProvider>();

    return Row(
      children: [
        _ActionButton(
          icon: tieneLike
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: '${publicacion.likesCount}',
          color: tieneLike ? AppColors.accent : null,
          onTap: () => provider.toggleLike(publicacion.id, miUid),
        ),
        const SizedBox(width: ThemeApp.spacingMd),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${publicacion.comentariosCount}',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Comentarios disponibles próximamente'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.share_rounded,
          label: '',
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).textTheme.bodySmall?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeApp.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeApp.spacingSm,
          vertical: ThemeApp.spacingXs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: effectiveColor),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: effectiveColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}