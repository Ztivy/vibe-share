import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibe_share/utils/theme_app.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool isDark;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    required this.isDark,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  bool _loading = false;
  bool _playing = false;
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

    // Si nunca se cargó la URL
    if (_player.processingState == ProcessingState.idle) {
      setState(() => _loading = true);
      try {
        await _player.setUrl(widget.url);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo cargar el audio.')),
          );
        }
        setState(() => _loading = false);
        return;
      }
      setState(() => _loading = false);
    }

    await _player.play();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
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
          // ── Botón play/pause ───────────────────────────────────────────
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
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),

          const SizedBox(width: ThemeApp.spacingMd),

          // ── Barra de progreso real ─────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview · Deezer',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  // Permite seek al tocar la barra
                  onTapDown: (details) {
                    if (_duration == Duration.zero) return;
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    // Ancho aproximado de la barra (total - botón - paddings)
                    const barStart = 56.0 + ThemeApp.spacingMd;
                    const barEnd = ThemeApp.spacingMd + 40.0 + ThemeApp.spacingMd;
                    final barWidth =
                        box.size.width - barStart - barEnd;
                    final tapX = details.localPosition.dx - barStart;
                    final ratio = (tapX / barWidth).clamp(0.0, 1.0);
                    final seekTo = _duration * ratio;
                    _player.seek(seekTo);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: widget.isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: ThemeApp.spacingMd),

          // ── Tiempo ─────────────────────────────────────────────────────
          Text(
            _duration > Duration.zero
                ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                : '0:30',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(width: ThemeApp.spacingMd),
        ],
      ),
    );
  }
}