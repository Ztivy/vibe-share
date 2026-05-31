import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vibe_share/network/deezer_api.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/providers/publicaciones_provider.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

class NuevaPublicacionScreen extends StatefulWidget {
  const NuevaPublicacionScreen({super.key});

  @override
  State<NuevaPublicacionScreen> createState() => _NuevaPublicacionScreenState();
}

class _NuevaPublicacionScreenState extends State<NuevaPublicacionScreen> {
  // ── Controladores ─────────────────────────────────────────────────────────
  final _busquedaCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _player = AudioPlayer();
  final _deezer = DeezerApi();
  final _uuid = const Uuid();

  // ── Estado ────────────────────────────────────────────────────────────────
  List<DeezerTrack> _resultados = [];
  DeezerTrack? _seleccionada;
  String _generoSeleccionado = StringsApp.generosMusicales.first;
  bool _buscando = false;
  bool _publicando = false;
  bool _reproduciendo = false;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    _descripcionCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Lógica ────────────────────────────────────────────────────────────────

  Future<void> _buscar() async {
    final q = _busquedaCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() { _buscando = true; _resultados = []; });
    final res = await _deezer.buscar(q);
    setState(() { _resultados = res; _buscando = false; });
  }

  Future<void> _togglePlay(DeezerTrack track) async {
    if (_seleccionada?.id == track.id && _reproduciendo) {
      await _player.pause();
      setState(() => _reproduciendo = false);
      return;
    }
    setState(() { _seleccionada = track; _reproduciendo = false; });
    try {
      await _player.setUrl(track.previewUrl);
      await _player.play();
      setState(() => _reproduciendo = true);
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _reproduciendo = false);
        }
      });
    } catch (e) {
      print('Player error: $e');
    }
  }

  Future<void> _publicar() async {
    if (_seleccionada == null) {
      _snack('Selecciona una canción primero');
      return;
    }
    await _player.pause();
    setState(() => _publicando = true);

    final auth = context.read<AuthProvider>();
    final provider = context.read<PublicacionesProvider>();
    final user = auth.usuarioActual!;

    final data = {
      'autorUid': user.uid,
      'autorNombre': user.nombre,
      'autorAvatarUrl': user.avatarUrl,
      'cancion': _seleccionada!.titulo,
      'artista': _seleccionada!.artista,
      'genero': _generoSeleccionado,
      'descripcion': _descripcionCtrl.text.trim(),
      'mediaUrl': _seleccionada!.previewUrl,
      'albumCover': _seleccionada!.albumCover ?? '',
      'tipoMedia': 'audio',
      'likes': [],
      'comentariosCount': 0,
      'esPremium': user.esPremium,
      'creadoEn': DateTime.now().toIso8601String(),
    };

    final id = await provider.crearPublicacion(data);
    setState(() => _publicando = false);

    if (!mounted) return;
    if (id != null) {
      _snack(StringsApp.newPostSuccess);
      _descripcionCtrl.clear();
      _busquedaCtrl.clear();
      setState(() { _seleccionada = null; _resultados = []; });
    } else {
      _snack(StringsApp.newPostError);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(StringsApp.newPostTitle),
        actions: [
          if (_publicando)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _publicar,
              child: Text(
                StringsApp.newPostPublish,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(ThemeApp.spacingMd),
        children: [
          // ── Canción seleccionada ────────────────────────────────────
          if (_seleccionada != null) ...[
            _SelectedSongCard(
              track: _seleccionada!,
              reproduciendo: _reproduciendo,
              onPlay: () => _togglePlay(_seleccionada!),
              isDark: isDark,
            ),
            const SizedBox(height: ThemeApp.spacingMd),
          ],

          // ── Buscador ────────────────────────────────────────────────
          TextField(
            controller: _busquedaCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar canción o artista...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _buscando
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send_rounded),
                      onPressed: _buscar,
                    ),
            ),
            onSubmitted: (_) => _buscar(),
          ),

          const SizedBox(height: ThemeApp.spacingMd),

          // ── Resultados ──────────────────────────────────────────────
          if (_resultados.isNotEmpty) ...[
            Text(
              'Resultados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ThemeApp.spacingSm),
            ..._resultados.map((track) => _TrackTile(
              track: track,
              seleccionada: _seleccionada?.id == track.id,
              reproduciendo: _seleccionada?.id == track.id && _reproduciendo,
              onTap: () => _togglePlay(track),
              isDark: isDark,
            )),
            const Divider(height: ThemeApp.spacingXl),
          ],

          // ── Descripción ─────────────────────────────────────────────
          TextField(
            controller: _descripcionCtrl,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: StringsApp.newPostHint,
            ),
          ),

          const SizedBox(height: ThemeApp.spacingMd),

          // ── Género ──────────────────────────────────────────────────
          Text(
            StringsApp.newPostGenre,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: ThemeApp.spacingSm),
          Wrap(
            spacing: ThemeApp.spacingSm,
            runSpacing: ThemeApp.spacingSm,
            children: StringsApp.generosMusicales.map((g) {
              final sel = _generoSeleccionado == g;
              return ChoiceChip(
                label: Text(g),
                selected: sel,
                onSelected: (_) => setState(() => _generoSeleccionado = g),
              );
            }).toList(),
          ),

          const SizedBox(height: ThemeApp.spacingXxl),
        ],
      ),
    );
  }
}

// ── Canción seleccionada ──────────────────────────────────────────────────────

class _SelectedSongCard extends StatelessWidget {
  final DeezerTrack track;
  final bool reproduciendo;
  final VoidCallback onPlay;
  final bool isDark;

  const _SelectedSongCard({
    required this.track,
    required this.reproduciendo,
    required this.onPlay,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeApp.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeApp.radiusLg),
      ),
      child: Row(
        children: [
          // Album cover
          ClipRRect(
            borderRadius: BorderRadius.circular(ThemeApp.radiusSm),
            child: track.albumCover != null
                ? Image.network(
                    track.albumCover!,
                    width: 56, height: 56,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56, height: 56,
                    color: Colors.white24,
                    child: const Icon(Icons.music_note_rounded,
                        color: Colors.white),
                  ),
          ),
          const SizedBox(width: ThemeApp.spacingMd),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.titulo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(track.artista,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                const Text('Preview 30s · Deezer',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),

          // Play
          IconButton(
            icon: Icon(
              reproduciendo
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_rounded,
              color: Colors.white,
              size: 36,
            ),
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}

// ── Tile de resultado ─────────────────────────────────────────────────────────

class _TrackTile extends StatelessWidget {
  final DeezerTrack track;
  final bool seleccionada;
  final bool reproduciendo;
  final VoidCallback onTap;
  final bool isDark;

  const _TrackTile({
    required this.track,
    required this.seleccionada,
    required this.reproduciendo,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeApp.spacingSm),
      decoration: BoxDecoration(
        color: seleccionada
            ? AppColors.primary.withOpacity(0.12)
            : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
        border: seleccionada
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeApp.spacingXs),
          child: track.albumCover != null
              ? Image.network(track.albumCover!,
                  width: 48, height: 48, fit: BoxFit.cover)
              : Container(
                  width: 48, height: 48,
                  color: AppColors.primary.withOpacity(0.2),
                  child: const Icon(Icons.music_note_rounded,
                      color: AppColors.primary),
                ),
        ),
        title: Text(track.titulo,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(track.artista,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: Icon(
            reproduciendo
                ? Icons.pause_circle_rounded
                : Icons.play_circle_outline_rounded,
            color: seleccionada ? AppColors.primary : AppColors.textHint,
            size: 30,
          ),
          onPressed: onTap,
        ),
        onTap: onTap,
      ),
    );
  }
}