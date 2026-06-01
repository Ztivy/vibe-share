import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_share/firebase/usuarios_firestore.dart';
import 'package:vibe_share/models/publicacion_model.dart';
import 'package:vibe_share/models/usuario_model.dart';
import 'package:vibe_share/providers/amigos_provider.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/providers/publicaciones_provider.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

class PerfilPublicoScreen extends StatefulWidget {
  /// UID del usuario cuyo perfil se va a mostrar.
  final String uid;

  /// Si ya tienes el modelo cargado puedes pasarlo directamente
  /// para evitar un fetch extra (opcional).
  final UsuarioModel? usuarioInicial;

  const PerfilPublicoScreen({
    super.key,
    required this.uid,
    this.usuarioInicial,
  });

  @override
  State<PerfilPublicoScreen> createState() => _PerfilPublicoScreenState();
}

class _PerfilPublicoScreenState extends State<PerfilPublicoScreen> {
  final _usuariosFirestore = UsuariosFirestore();

  UsuarioModel? _usuario;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    if (widget.usuarioInicial != null) {
      _usuario = widget.usuarioInicial;
      _cargando = false;
    } else {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    final u = await _usuariosFirestore.getUsuario(widget.uid);
    if (mounted) setState(() { _usuario = u; _cargando = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_usuario == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Usuario no encontrado.')),
      );
    }

    return _PerfilPublicoView(usuario: _usuario!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PerfilPublicoView extends StatelessWidget {
  final UsuarioModel usuario;
  const _PerfilPublicoView({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final yo = auth.usuarioActual;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Relación con el usuario actual
    final soyYo = yo?.uid == usuario.uid;
    final esAmigo = yo?.amigos.contains(usuario.uid) ?? false;
    final enviada = yo?.solicitudesEnviadas.contains(usuario.uid) ?? false;
    final recibida = yo?.solicitudesRecibidas.contains(usuario.uid) ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar con avatar de fondo ──────────────────────────────
          _PerfilSliverAppBar(usuario: usuario, isDark: isDark),

          // ── Cuerpo ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeApp.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: ThemeApp.spacingMd),

                  // Nombre + badge premium
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          usuario.nombre,
                          style: Theme.of(context).textTheme.headlineLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (usuario.esPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeApp.spacingSm,
                            vertical: ThemeApp.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD166), Color(0xFFFF9A3C)],
                            ),
                            borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: ThemeApp.spacingXs),

                  // Email
                  Text(
                    usuario.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: ThemeApp.spacingMd),

                  // Botón de acción (solo si no es mi propio perfil)
                  if (!soyYo)
                    _BotonAccion(
                      usuario: usuario,
                      esAmigo: esAmigo,
                      enviada: enviada,
                      recibida: recibida,
                    ),

                  if (!soyYo) const SizedBox(height: ThemeApp.spacingMd),

                  // ── Stats ────────────────────────────────────────────
                  _StatsRow(usuario: usuario),

                  const Divider(height: ThemeApp.spacingXl),

                  // ── Bio ──────────────────────────────────────────────
                  if (usuario.bio.isNotEmpty) ...[
                    Text(
                      'Bio',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: ThemeApp.spacingSm),
                    Text(
                      usuario.bio,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(height: ThemeApp.spacingXl),
                  ],

                  // ── Géneros ──────────────────────────────────────────
                  if (usuario.generosInteres.isNotEmpty) ...[
                    Text(
                      StringsApp.profileGenres,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: ThemeApp.spacingSm),
                    Wrap(
                      spacing: ThemeApp.spacingSm,
                      runSpacing: ThemeApp.spacingSm,
                      children: usuario.generosInteres
                          .map((g) => Chip(
                                label: Text(g),
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                side: BorderSide.none,
                                labelStyle: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))
                          .toList(),
                    ),
                    const Divider(height: ThemeApp.spacingXl),
                  ],

                  // ── Publicaciones ────────────────────────────────────
                  _PublicacionesHeader(uid: usuario.uid),
                ],
              ),
            ),
          ),

          // ── Lista de publicaciones ───────────────────────────────────
          _PublicacionesSliver(uid: usuario.uid, isDark: isDark),

          const SliverToBoxAdapter(
            child: SizedBox(height: ThemeApp.spacingXxl),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SliverAppBar con gradiente y avatar grande
// ─────────────────────────────────────────────────────────────────────────────

class _PerfilSliverAppBar extends StatelessWidget {
  final UsuarioModel usuario;
  final bool isDark;
  const _PerfilSliverAppBar({required this.usuario, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo degradado
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF9B8FFF)],
                ),
              ),
            ),

            // Blobs decorativos
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Avatar centrado
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: usuario.avatarUrl.isNotEmpty
                        ? Image.network(
                            usuario.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _AvatarFallback(),
                          )
                        : _AvatarFallback(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón de acción (Agregar / Pendiente / Amigos / Aceptar)
// ─────────────────────────────────────────────────────────────────────────────

class _BotonAccion extends StatefulWidget {
  final UsuarioModel usuario;
  final bool esAmigo;
  final bool enviada;
  final bool recibida;

  const _BotonAccion({
    required this.usuario,
    required this.esAmigo,
    required this.enviada,
    required this.recibida,
  });

  @override
  State<_BotonAccion> createState() => _BotonAccionState();
}

class _BotonAccionState extends State<_BotonAccion> {
  bool _loading = false;
  late bool _enviada;

  @override
  void initState() {
    super.initState();
    _enviada = widget.enviada;
  }

  Future<void> _enviar() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _enviada = true;
    });

    final auth = context.read<AuthProvider>();
    final yo = auth.usuarioActual!;
    final ok = await context.read<AmigosProvider>().enviarSolicitud(
          yo.uid,
          widget.usuario.uid,
          miNombre: yo.nombre,
          miAvatar: yo.avatarUrl,
        );

    if (!ok) setState(() => _enviada = false);
    if (ok) auth.refrescarUsuario();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _cancelar() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _enviada = false;
    });

    final auth = context.read<AuthProvider>();
    final ok = await context
        .read<AmigosProvider>()
        .cancelarSolicitud(auth.usuarioActual!.uid, widget.usuario.uid);

    if (!ok) setState(() => _enviada = true);
    if (ok) auth.refrescarUsuario();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _aceptar() async {
    if (_loading) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final yo = auth.usuarioActual!;
    final ok = await context.read<AmigosProvider>().aceptarSolicitud(
          yo.uid,
          widget.usuario.uid,
          miNombre: yo.nombre,
          miAvatar: yo.avatarUrl,
        );

    if (ok) auth.refrescarUsuario();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _rechazar() async {
    if (_loading) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final ok = await context
        .read<AmigosProvider>()
        .rechazarSolicitud(auth.usuarioActual!.uid, widget.usuario.uid);

    if (ok) auth.refrescarUsuario();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: ThemeApp.spacingMd),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (widget.esAmigo) {
      return _fullChip(
        icon: Icons.check_rounded,
        label: 'Amigos',
        color: AppColors.success,
      );
    }

    if (widget.recibida) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _rechazar,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text(StringsApp.friendsDecline),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(width: ThemeApp.spacingSm),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _aceptar,
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text(StringsApp.friendsAccept),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
          ),
        ],
      );
    }

    if (_enviada) {
      return Row(
        children: [
          Expanded(
            child: _fullChip(
              icon: Icons.schedule_rounded,
              label: StringsApp.friendsPending,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(width: ThemeApp.spacingSm),
          OutlinedButton.icon(
            onPressed: _cancelar,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _enviar,
        icon: const Icon(Icons.person_add_rounded, size: 18),
        label: Text(StringsApp.friendsAdd),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _fullChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: ThemeApp.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final UsuarioModel usuario;
  const _StatsRow({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicacionesProvider>();

    return StreamBuilder<List<PublicacionModel>>(
      stream: provider.publicacionesDeUsuario(usuario.uid),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              label: StringsApp.profileFriends,
              value: '${usuario.amigos.length}',
            ),
            _divider(),
            _StatItem(
              label: StringsApp.profilePosts,
              value: snap.connectionState == ConnectionState.waiting
                  ? '…'
                  : '$count',
            ),
            _divider(),
            _StatItem(
              label: StringsApp.profileGenres,
              value: '${usuario.generosInteres.length}',
            ),
          ],
        );
      },
    );
  }

  Widget _divider() => Container(height: 36, width: 1, color: AppColors.border);
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Publicaciones
// ─────────────────────────────────────────────────────────────────────────────

class _PublicacionesHeader extends StatelessWidget {
  final String uid;
  const _PublicacionesHeader({required this.uid});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicacionesProvider>();

    return StreamBuilder<List<PublicacionModel>>(
      stream: provider.publicacionesDeUsuario(uid),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return Row(
          children: [
            Text(
              StringsApp.profilePosts,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: ThemeApp.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PublicacionesSliver extends StatelessWidget {
  final String uid;
  final bool isDark;
  const _PublicacionesSliver({required this.uid, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicacionesProvider>();

    return StreamBuilder<List<PublicacionModel>>(
      stream: provider.publicacionesDeUsuario(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(ThemeApp.spacingXl),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final publicaciones = snap.data ?? [];

        if (publicaciones.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(ThemeApp.spacingXl),
              child: Column(
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 48,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: ThemeApp.spacingSm),
                  Text(
                    'Sin publicaciones aún',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeApp.spacingMd,
            vertical: ThemeApp.spacingSm,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _MiniCard(
                publicacion: publicaciones[i],
                isDark: isDark,
              ),
              childCount: publicaciones.length,
            ),
          ),
        );
      },
    );
  }
}

class _MiniCard extends StatelessWidget {
  final PublicacionModel publicacion;
  final bool isDark;
  const _MiniCard({required this.publicacion, required this.isDark});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeApp.spacingSm),
      padding: const EdgeInsets.all(ThemeApp.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Album cover
          ClipRRect(
            borderRadius: BorderRadius.circular(ThemeApp.spacingSm),
            child: publicacion.albumCover != null &&
                    publicacion.albumCover!.isNotEmpty
                ? Image.network(
                    publicacion.albumCover!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _MusicIcon(),
                  )
                : _MusicIcon(),
          ),

          const SizedBox(width: ThemeApp.spacingMd),

          // Info
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
                Text(
                  publicacion.artista,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (publicacion.descripcion.isNotEmpty)
                  Text(
                    publicacion.descripcion,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          const SizedBox(width: ThemeApp.spacingSm),

          // Likes + género + fecha
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      size: 14, color: AppColors.accent),
                  const SizedBox(width: 3),
                  Text(
                    '${publicacion.likesCount}',
                    style:
                        AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                ),
                child: Text(
                  publicacion.genero,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _timeAgo(publicacion.creadoEn),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MusicIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeApp.spacingSm),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 26),
    );
  }
}