// lib/screens/comentarios_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_share/firebase/comentarios_firestore.dart';
import 'package:vibe_share/models/comentario_model.dart';
import 'package:vibe_share/models/publicacion_model.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/utils/theme_app.dart';

/// Abre el bottom sheet de comentarios.
/// Llama esto desde el botón de comentarios en el feed.
void mostrarComentarios(BuildContext context, PublicacionModel publicacion) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ComentariosSheet(publicacion: publicacion),
  );
}

class ComentariosSheet extends StatefulWidget {
  final PublicacionModel publicacion;

  const ComentariosSheet({super.key, required this.publicacion});

  @override
  State<ComentariosSheet> createState() => _ComentariosSheetState();
}

class _ComentariosSheetState extends State<ComentariosSheet> {
  final _comentariosFirestore = ComentariosFirestore();
  final _textoCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _enviando = false;

  @override
  void dispose() {
    _textoCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _textoCtrl.text.trim();
    if (texto.isEmpty || _enviando) return;

    final auth = context.read<AuthProvider>();
    final user = auth.usuarioActual;
    if (user == null) return;

    setState(() => _enviando = true);

    final comentario = ComentarioModel(
      id: '',
      autorUid: user.uid,
      autorNombre: user.nombre,
      autorAvatarUrl: user.avatarUrl,
      texto: texto,
      creadoEn: DateTime.now(),
    );

    final ok = await _comentariosFirestore.agregarComentario(
      publicacionId: widget.publicacion.id,
      comentario: comentario,
    );

    if (ok) {
      _textoCtrl.clear();
      // Scroll al final tras agregar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    if (mounted) setState(() => _enviando = false);
  }

  Future<void> _eliminar(ComentarioModel comentario) async {
    await _comentariosFirestore.eliminarComentario(
      publicacionId: widget.publicacion.id,
      comentarioId: comentario.id,
    );
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final miUid = context.read<AuthProvider>().usuarioActual?.uid ?? '';
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: screenHeight * 0.75 + bottomInset,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeApp.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // ── Handle ────────────────────────────────────────────────────
          const SizedBox(height: ThemeApp.spacingMd),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(ThemeApp.radiusFull),
            ),
          ),
          const SizedBox(height: ThemeApp.spacingMd),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeApp.spacingMd,
            ),
            child: Row(
              children: [
                Text(
                  'Comentarios',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: ThemeApp.spacingSm),
                StreamBuilder<List<ComentarioModel>>(
                  stream: _comentariosFirestore
                      .streamComentarios(widget.publicacion.id),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(ThemeApp.radiusFull),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Lista de comentarios ──────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<ComentarioModel>>(
              stream: _comentariosFirestore
                  .streamComentarios(widget.publicacion.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comentarios = snap.data ?? [];

                if (comentarios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: AppColors.textHint.withOpacity(0.4),
                        ),
                        const SizedBox(height: ThemeApp.spacingSm),
                        Text(
                          'Sé el primero en comentar',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeApp.spacingMd,
                    vertical: ThemeApp.spacingSm,
                  ),
                  itemCount: comentarios.length,
                  itemBuilder: (_, i) {
                    final c = comentarios[i];
                    final esMio = c.autorUid == miUid;

                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: ThemeApp.spacingMd),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                AppColors.primary.withOpacity(0.15),
                            backgroundImage: c.autorAvatarUrl.isNotEmpty
                                ? NetworkImage(c.autorAvatarUrl)
                                : null,
                            child: c.autorAvatarUrl.isEmpty
                                ? const Icon(Icons.person_rounded,
                                    size: 18, color: AppColors.primary)
                                : null,
                          ),

                          const SizedBox(width: ThemeApp.spacingSm),

                          // Burbuja
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: ThemeApp.spacingMd,
                                    vertical: ThemeApp.spacingSm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.only(
                                      topRight: const Radius.circular(
                                          ThemeApp.radiusMd),
                                      bottomLeft: const Radius.circular(
                                          ThemeApp.radiusMd),
                                      bottomRight: const Radius.circular(
                                          ThemeApp.radiusMd),
                                      topLeft: Radius.circular(
                                          esMio ? ThemeApp.radiusMd : 0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.autorNombre,
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.texto,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),

                                // Tiempo + eliminar
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: ThemeApp.spacingSm, top: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        _timeAgo(c.creadoEn),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 11),
                                      ),
                                      if (esMio) ...[
                                        const SizedBox(
                                            width: ThemeApp.spacingSm),
                                        GestureDetector(
                                          onTap: () => _eliminar(c),
                                          child: Text(
                                            'Eliminar',
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: AppColors.error,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ── Input ─────────────────────────────────────────────────────
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: ThemeApp.spacingMd,
              right: ThemeApp.spacingMd,
              top: ThemeApp.spacingSm,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + ThemeApp.spacingMd,
            ),
            child: Row(
              children: [
                // Avatar del usuario actual
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    final url = auth.usuarioActual?.avatarUrl ?? '';
                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage:
                          url.isNotEmpty ? NetworkImage(url) : null,
                      child: url.isEmpty
                          ? const Icon(Icons.person_rounded,
                              size: 18, color: AppColors.primary)
                          : null,
                    );
                  },
                ),

                const SizedBox(width: ThemeApp.spacingSm),

                // TextField
                Expanded(
                  child: TextField(
                    controller: _textoCtrl,
                    maxLines: 1,
                    maxLength: 300,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviar(),
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: ThemeApp.spacingMd,
                        vertical: ThemeApp.spacingSm,
                      ),
                      suffixIcon: _enviando
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded,
                                  color: AppColors.primary),
                              onPressed: _enviar,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}