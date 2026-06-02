// lib/providers/publicaciones_provider.dart

import 'package:flutter/material.dart';
import 'package:vibe_share/firebase/notificaciones_push.dart';
import 'package:vibe_share/firebase/publicaciones_firestore.dart';
import 'package:vibe_share/models/publicacion_model.dart';

class PublicacionesProvider extends ChangeNotifier {
  final PublicacionesFirestore _firestore = PublicacionesFirestore();
  final NotificacionesPush _push = NotificacionesPush();

  bool isLoading = false;
  String? error;

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<List<PublicacionModel>> get feedGlobal =>
      _firestore.streamFeedGlobal();

  Stream<List<PublicacionModel>> feedAmigos(List<String> amigosUids) =>
      _firestore.streamFeedAmigos(amigosUids);

  Stream<List<PublicacionModel>> sugerenciasPorGenero(List<String> generos) =>
      _firestore.streamSugerenciasPorGenero(generos);

  Stream<List<PublicacionModel>> publicacionesDeUsuario(String uid) =>
      _firestore.streamPublicacionesDeUsuario(uid);

  // ── Crear ─────────────────────────────────────────────────────────────────

  Future<String?> crearPublicacion(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final id = await _firestore.crearPublicacion(data);
    if (id == null) error = 'No se pudo crear la publicación.';

    isLoading = false;
    notifyListeners();
    return id;
  }

  // ── Like ──────────────────────────────────────────────────────────────────

  /// [miUid] → quien da el like
  /// [miNombre] → nombre de quien da el like
  /// [publicacion] → la publicación completa (para saber el autor y la canción)
  Future<void> toggleLike({
    required String publicacionId,
    required String miUid,
    required String miNombre,
    required PublicacionModel publicacion,
  }) async {
    final tenieLikeAntes = publicacion.tieneLike(miUid);

    await _firestore.toggleLike(publicacionId, miUid);

    // Solo notificar si ES un like nuevo (no un unlike)
    // y si no es la propia publicación del usuario
    if (!tenieLikeAntes && publicacion.autorUid != miUid) {
      await _push.notificarLike(
        autorUid: publicacion.autorUid,
        remitenteNombre: miNombre,
        cancion: publicacion.cancion,
      );
    }
  }

  // ── Eliminar ──────────────────────────────────────────────────────────────

  Future<bool> eliminarPublicacion(String publicacionId) async {
    isLoading = true;
    notifyListeners();
    final ok = await _firestore.eliminarPublicacion(publicacionId);
    isLoading = false;
    notifyListeners();
    return ok;
  }
}