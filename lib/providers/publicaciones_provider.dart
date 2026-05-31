import 'package:flutter/material.dart';
import 'package:vibe_share/firebase/publicaciones_firestore.dart';
import 'package:vibe_share/models/publicacion_model.dart';

class PublicacionesProvider extends ChangeNotifier {
  final PublicacionesFirestore _firestore = PublicacionesFirestore();

  bool isLoading = false;
  String? error;

  // ── Streams públicos ──────────────────────────────────────────────────────

  Stream<List<PublicacionModel>> get feedGlobal =>
      _firestore.streamFeedGlobal();

  Stream<List<PublicacionModel>> feedAmigos(List<String> amigosUids) =>
      _firestore.streamFeedAmigos(amigosUids);

  Stream<List<PublicacionModel>> sugerenciasPorGenero(List<String> generos) =>
      _firestore.streamSugerenciasPorGenero(generos);

  Stream<List<PublicacionModel>> publicacionesDeUsuario(String uid) =>
      _firestore.streamPublicacionesDeUsuario(uid);

  // ── Crear publicación ─────────────────────────────────────────────────────

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

  Future<void> toggleLike(String publicacionId, String uid) async {
    await _firestore.toggleLike(publicacionId, uid);
    // El stream de Firestore actualizará la UI automáticamente
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
