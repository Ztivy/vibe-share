import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_share/models/usuario_model.dart';
import 'package:vibe_share/providers/amigos_provider.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

class AmigosScreen extends StatefulWidget {
  const AmigosScreen({super.key});

  @override
  State<AmigosScreen> createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarSugerencias());
  }

  void _cargarSugerencias() {
    final auth = context.read<AuthProvider>();
    final user = auth.usuarioActual;
    if (user == null) return;
    context.read<AmigosProvider>().cargarSugerencias(
          user.generosInteres,
          user.uid,
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringsApp.friendsTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Buscar'),
            Tab(text: 'Solicitudes'),
            Tab(text: 'Sugerencias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BuscarTab(searchCtrl: _searchCtrl),
          const _SolicitudesTab(),
          const _SugerenciasTab(),
        ],
      ),
    );
  }
}

// ── Tab: Buscar ───────────────────────────────────────────────────────────────

class _BuscarTab extends StatefulWidget {
  final TextEditingController searchCtrl;
  const _BuscarTab({required this.searchCtrl});

  @override
  State<_BuscarTab> createState() => _BuscarTabState();
}

class _BuscarTabState extends State<_BuscarTab> {
  // Debounce simple sin dependencia externa
  Future<void> _onChanged(String q, BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Solo busca si el texto sigue siendo el mismo tras la espera
    if (widget.searchCtrl.text == q) {
      context.read<AmigosProvider>().buscar(q);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AmigosProvider>();
    final auth = context.read<AuthProvider>();
    final miUid = auth.usuarioActual?.uid ?? '';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(ThemeApp.spacingMd),
          child: TextField(
            controller: widget.searchCtrl,
            decoration: InputDecoration(
              hintText: StringsApp.friendsSearch,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: provider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : widget.searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            widget.searchCtrl.clear();
                            context.read<AmigosProvider>().buscar('');
                            setState(() {});
                          },
                        )
                      : null,
            ),
            onChanged: (q) {
              setState(() {}); // para actualizar el botón clear
              _onChanged(q, context);
            },
            onSubmitted: (q) => context.read<AmigosProvider>().buscar(q),
            textInputAction: TextInputAction.search,
          ),
        ),
        Expanded(
          child: provider.resultadosBusqueda.isEmpty
              ? _EmptySearch(hasQuery: widget.searchCtrl.text.isNotEmpty)
              : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeApp.spacingMd,
                      ),
                      itemCount: provider.resultadosBusqueda.length,
                      itemBuilder: (_, i) => _UsuarioTile(
                        usuario: provider.resultadosBusqueda[i],
                        miUid: miUid,
                        miUsuario: auth.usuarioActual!,
                      ),
                    ),
        ),
      ],
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final bool hasQuery;
  const _EmptySearch({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery
                ? Icons.person_search_rounded
                : Icons.search_rounded,
            size: 64,
            color: AppColors.textHint.withOpacity(0.4),
          ),
          const SizedBox(height: ThemeApp.spacingMd),
          Text(
            hasQuery
                ? 'Sin resultados para esa búsqueda'
                : 'Busca usuarios por nombre',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


// ── Tab: Solicitudes ──────────────────────────────────────────────────────────

class _SolicitudesTab extends StatelessWidget {
  const _SolicitudesTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.usuarioActual;
    if (user == null) return const SizedBox.shrink();

    final recibidas = user.solicitudesRecibidas;
    final enviadas = user.solicitudesEnviadas;

    if (recibidas.isEmpty && enviadas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mark_email_unread_rounded,
              size: 64,
              color: AppColors.textHint.withOpacity(0.4),
            ),
            const SizedBox(height: ThemeApp.spacingMd),
            Text(
              'No tienes solicitudes pendientes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(ThemeApp.spacingMd),
      children: [
        // ── Recibidas ───────────────────────────────────────────────
        if (recibidas.isNotEmpty) ...[
          _SectionHeader(
            title: StringsApp.friendsRequests,
            count: recibidas.length,
          ),
          const SizedBox(height: ThemeApp.spacingSm),
          ...recibidas.map(
            (uid) => _SolicitudRecibidaTile(
              origenUid: uid,
              miUid: user.uid,
            ),
          ),
          const SizedBox(height: ThemeApp.spacingLg),
        ],

        // ── Enviadas ─────────────────────────────────────────────────
        if (enviadas.isNotEmpty) ...[
          _SectionHeader(
            title: 'Enviadas',
            count: enviadas.length,
          ),
          const SizedBox(height: ThemeApp.spacingSm),
          ...enviadas.map(
            (uid) => _SolicitudEnviadaTile(
              destinoUid: uid,
              miUid: user.uid,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Tab: Sugerencias ──────────────────────────────────────────────────────────

class _SugerenciasTab extends StatelessWidget {
  const _SugerenciasTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AmigosProvider>();
    final auth = context.read<AuthProvider>();
    final miUid = auth.usuarioActual?.uid ?? '';

    if (provider.sugerencias.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: AppColors.textHint.withOpacity(0.4),
            ),
            const SizedBox(height: ThemeApp.spacingMd),
            Text(
              'Agrega géneros en tu perfil\npara ver sugerencias',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(ThemeApp.spacingMd),
      children: [
        _SectionHeader(
          title: StringsApp.friendsSuggestions,
          count: provider.sugerencias.length,
        ),
        const SizedBox(height: ThemeApp.spacingSm),
        ...provider.sugerencias.map(
          (u) => _UsuarioTile(
            usuario: u,
            miUid: miUid,
            miUsuario: auth.usuarioActual!,
          ),
        ),
      ],
    );
  }
}

// ── Tile de usuario (buscar + sugerencias) ────────────────────────────────────

class _UsuarioTile extends StatelessWidget {
  final UsuarioModel usuario;
  final String miUid;
  final UsuarioModel miUsuario;

  const _UsuarioTile({
    required this.usuario,
    required this.miUid,
    required this.miUsuario,
  });

  @override
  Widget build(BuildContext context) {
    if (usuario.uid == miUid) return const SizedBox.shrink();

    final esAmigo = miUsuario.amigos.contains(usuario.uid);
    final enviada = miUsuario.solicitudesEnviadas.contains(usuario.uid);
    final recibida = miUsuario.solicitudesRecibidas.contains(usuario.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeApp.spacingSm),
      padding: const EdgeInsets.all(ThemeApp.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage: usuario.avatarUrl.isNotEmpty
                ? NetworkImage(usuario.avatarUrl)
                : null,
            child: usuario.avatarUrl.isEmpty
                ? const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 26)
                : null,
          ),

          const SizedBox(width: ThemeApp.spacingMd),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (usuario.generosInteres.isNotEmpty)
                  Text(
                    usuario.generosInteres.take(3).join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          const SizedBox(width: ThemeApp.spacingSm),

          // Botón acción
          _AccionBoton(
            esAmigo: esAmigo,
            enviada: enviada,
            recibida: recibida,
            miUid: miUid,
            destinoUid: usuario.uid,
          ),
        ],
      ),
    );
  }
}

// ── Botón de acción contextual ────────────────────────────────────────────────

class _AccionBoton extends StatefulWidget {
  final bool esAmigo;
  final bool enviada;
  final bool recibida;
  final String miUid;
  final String destinoUid;

  const _AccionBoton({
    required this.esAmigo,
    required this.enviada,
    required this.recibida,
    required this.miUid,
    required this.destinoUid,
  });

  @override
  State<_AccionBoton> createState() => _AccionBotonState();
}

class _AccionBotonState extends State<_AccionBoton> {
  bool _loading = false;
  bool _enviada = false; // estado local optimista

  @override
  void initState() {
    super.initState();
    _enviada = widget.enviada;
  }

  Future<void> _accion() async {
    if (_loading) return;
    setState(() => _loading = true);

    final provider = context.read<AmigosProvider>();
    final auth = context.read<AuthProvider>();
    final miNombre = auth.usuarioActual?.nombre ?? '';
    final miAvatar = auth.usuarioActual?.avatarUrl ?? '';

    bool ok = false;
    if (widget.recibida) {
      ok = await provider.aceptarSolicitud(
        widget.miUid,
        widget.destinoUid,
        miNombre: miNombre,
        miAvatar: miAvatar,
      );
    } else if (!_enviada && !widget.esAmigo) {
      // Actualización optimista: mostrar "Pendiente" inmediatamente
      setState(() => _enviada = true);
      ok = await provider.enviarSolicitud(
        widget.miUid,
        widget.destinoUid,
        miNombre: miNombre,
        miAvatar: miAvatar,
      );
      if (!ok) {
        // Revertir si falló
        setState(() => _enviada = false);
      }
    }

    if (ok) {
      auth.refrescarUsuario();
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Usar _enviada (local) en lugar de widget.enviada
    final estaEnviada = _enviada || widget.enviada;

    if (widget.esAmigo) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeApp.spacingMd,
          vertical: ThemeApp.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              'Amigos',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
            ),
          ],
        ),
      );
    }

    if (estaEnviada) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeApp.spacingMd,
          vertical: ThemeApp.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.textHint.withOpacity(0.12),
          borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.textHint,
                ),
              )
            else
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              StringsApp.friendsPending,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return _loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : ElevatedButton(
            onPressed: _accion,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.recibida ? AppColors.success : AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeApp.spacingMd,
                vertical: ThemeApp.spacingSm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              widget.recibida ? StringsApp.friendsAccept : StringsApp.friendsAdd,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          );
  }
}

// ── Tile solicitud recibida ───────────────────────────────────────────────────

class _SolicitudRecibidaTile extends StatefulWidget {
  final String origenUid;
  final String miUid;

  const _SolicitudRecibidaTile({
    required this.origenUid,
    required this.miUid,
  });

  @override
  State<_SolicitudRecibidaTile> createState() => _SolicitudRecibidaTileState();
}

class _SolicitudRecibidaTileState extends State<_SolicitudRecibidaTile> {
  UsuarioModel? _usuario;
  bool _loading = true;
  bool _accionando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    // Reutilizamos UsuariosFirestore vía AmigosProvider no es directo,
    // así que hacemos la llamada desde el provider de auth
    final auth = context.read<AuthProvider>();
    _usuario = await auth.getUsuarioPorUid(widget.origenUid);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _aceptar() async {
    setState(() => _accionando = true);
    final provider = context.read<AmigosProvider>();
    final auth = context.read<AuthProvider>();
    await provider.aceptarSolicitud(
      widget.miUid,
      widget.origenUid,
      miNombre: auth.usuarioActual?.nombre ?? '',
      miAvatar: auth.usuarioActual?.avatarUrl ?? '',
    );
    auth.refrescarUsuario();
    if (mounted) setState(() => _accionando = false);
  }

  Future<void> _rechazar() async {
    setState(() => _accionando = true);
    final provider = context.read<AmigosProvider>();
    final auth = context.read<AuthProvider>();
    await provider.rechazarSolicitud(widget.miUid, widget.origenUid);
    auth.refrescarUsuario();
    if (mounted) setState(() => _accionando = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: ThemeApp.spacingSm),
        child: LinearProgressIndicator(),
      );
    }

    final nombre = _usuario?.nombre ?? widget.origenUid;
    final avatar = _usuario?.avatarUrl ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeApp.spacingSm),
      padding: const EdgeInsets.all(ThemeApp.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 22)
                : null,
          ),
          const SizedBox(width: ThemeApp.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  StringsApp.notifFriendReq,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (_accionando)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              children: [
                // Rechazar
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.error, size: 22),
                  onPressed: _rechazar,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: ThemeApp.spacingSm),
                // Aceptar
                IconButton(
                  icon: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 22),
                  onPressed: _aceptar,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success.withOpacity(0.1),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Tile solicitud enviada ────────────────────────────────────────────────────

class _SolicitudEnviadaTile extends StatefulWidget {
  final String destinoUid;
  final String miUid;

  const _SolicitudEnviadaTile({
    required this.destinoUid,
    required this.miUid,
  });

  @override
  State<_SolicitudEnviadaTile> createState() => _SolicitudEnviadaTileState();
}

class _SolicitudEnviadaTileState extends State<_SolicitudEnviadaTile> {
  UsuarioModel? _usuario;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final auth = context.read<AuthProvider>();
    _usuario = await auth.getUsuarioPorUid(widget.destinoUid);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: ThemeApp.spacingSm),
        child: LinearProgressIndicator(),
      );
    }

    final nombre = _usuario?.nombre ?? widget.destinoUid;
    final avatar = _usuario?.avatarUrl ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 22)
                : null,
          ),
          const SizedBox(width: ThemeApp.spacingMd),
          Expanded(
            child: Text(nombre,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeApp.spacingMd,
              vertical: ThemeApp.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.12),
              borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
            ),
            child: Text(
              StringsApp.friendsPending,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
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
  }
}