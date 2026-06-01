// lib/widgets/audio_player_widget.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibe_share/network/deezer_api.dart';
import 'package:vibe_share/utils/theme_app.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String cancion;
  final String artista;
  final bool isDark;

  const AudioPlayerWidget({
    super.key,
    required this.cancion,
    required this.artista,
    required this.isDark,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  final DeezerApi _deezer = DeezerApi();

  bool _loading = false;
  bool _playing = false;
  bool _error = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _player.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() => _duration = dur);
    });

    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playing = false;
          _position = Duration.zero;
        });
        _player.seek(Duration.zero);
      }
      setState(() {
        _playing = state.playing &&
            state.processingState != ProcessingState.completed;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_loading) return;

    if (_playing) {
      await _player.pause();
      return;
    }

    // Siempre buscar URL fresca en Deezer al presionar play
    setState(() { _loading = true; _error = false; });

    try {
      final query = '${widget.artista} ${widget.cancion}';
      final resultados = await _deezer.buscar(query);

      if (resultados.isEmpty) {
        throw Exception('No se encontró la canción en Deezer');
      }

      final previewUrl = resultados.first.previewUrl;

      // Resetear player y cargar URL fresca
      await _player.stop();
      await _player.setUrl(previewUrl);
      await _player.play();

    } catch (e) {
      if (mounted) {
        setState(() => _error = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar el preview.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
        border: Border.all(
          color: widget.isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // ── Botón play/pause ──────────────────────────────────────────
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ThemeApp.radiusMd),
                  bottomLeft: Radius.circular(ThemeApp.radiusMd),
                ),
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      _error
                          ? Icons.refresh_rounded
                          : _playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),

          const SizedBox(width: ThemeApp.spacingMd),

          // ── Barra de progreso ─────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _error
                      ? 'Error · toca para reintentar'
                      : 'Preview · Deezer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _error ? AppColors.error : null,
                      ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: widget.isDark
                        ? AppColors.borderDark
                        : AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      _error ? AppColors.error : AppColors.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: ThemeApp.spacingMd),

          // ── Tiempo ────────────────────────────────────────────────────
          Text(
            _duration > Duration.zero
                ? '${_fmt(_position)} / ${_fmt(_duration)}'
                : '0:30',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(width: ThemeApp.spacingMd),
        ],
      ),
    );
  }
}