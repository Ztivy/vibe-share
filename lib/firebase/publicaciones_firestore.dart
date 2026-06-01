import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_share/models/publicacion_model.dart';

class PublicacionesFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _col;

  PublicacionesFirestore() {
    _col = _firestore.collection('publicaciones');
  }

  Future<bool> actualizarAutorNombre(String uid, String nombre) async {
    try {
      final query = await _col.where('autorUid', isEqualTo: uid).get();
      if (query.docs.isEmpty) return true;

      var batch = _firestore.batch();
      var batchCount = 0;

      for (final doc in query.docs) {
        batch.update(doc.reference, {'autorNombre': nombre});
        batchCount++;

        if (batchCount == 500) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) await batch.commit();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('actualizarAutorNombre error: $e');
      return false;
    }
  }

  // ── Crear ─────────────────────────────────────────────────────────────────

  Future<String?> crearPublicacion(Map<String, dynamic> data) async {
    try {
      final ref = await _col.add(data);
      return ref.id;
    } catch (e) {
      // ignore: avoid_print
      print('crearPublicacion error: $e');
      return null;
    }
  }

  // ── Streams ───────────────────────────────────────────────────────────────

  /// Feed general — todas las publicaciones ordenadas por fecha.
  Stream<List<PublicacionModel>> streamFeedGlobal({int limit = 30}) {
    return _col
        .orderBy('creadoEn', descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapSnapshot);
  }

  /// Feed de amigos — publicaciones de una lista de UIDs.
  Stream<List<PublicacionModel>> streamFeedAmigos(
  List<String> amigosUids, {
  int limit = 30,
}) {
  if (amigosUids.isEmpty) return Stream.value([]);
  final uids = amigosUids.take(30).toList();
  return _col
      .where('autorUid', whereIn: uids)
      .limit(limit)
      .snapshots()
      .map((snap) {
        final lista = _mapSnapshot(snap);
        lista.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
        return lista;
      });
}

Stream<List<PublicacionModel>> streamSugerenciasPorGenero(
  List<String> generos, {
  int limit = 20,
}) {
  if (generos.isEmpty) return Stream.value([]);
  return _col
      .where('genero', whereIn: generos.take(10).toList())
      .limit(limit)
      .snapshots()
      .map((snap) {
        final lista = _mapSnapshot(snap);
        lista.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
        return lista;
      });
}

  /// Publicaciones de un usuario específico.
  Stream<List<PublicacionModel>> streamPublicacionesDeUsuario(
  String uid, {
  int limit = 50,
}) {
  return _col
      .where('autorUid', isEqualTo: uid)
      .limit(limit)
      .snapshots()
      .map((snap) {
        final lista = _mapSnapshot(snap);
        lista.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
        return lista;
      });
}

  // ── Likes ─────────────────────────────────────────────────────────────────

  Future<bool> toggleLike(String publicacionId, String uid) async {
    try {
      final ref = _col.doc(publicacionId);
      final snap = await ref.get();
      if (!snap.exists) return false;

      final data = snap.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] as List? ?? []);
      final tieneLike = likes.contains(uid);

      await ref.update({
        'likes': tieneLike
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid]),
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('toggleLike error: $e');
      return false;
    }
  }

  // ── Eliminar ──────────────────────────────────────────────────────────────

  Future<bool> eliminarPublicacion(String publicacionId) async {
    try {
      await _col.doc(publicacionId).delete();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('eliminarPublicacion error: $e');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<PublicacionModel> _mapSnapshot(QuerySnapshot snap) {
    return snap.docs
        .map((d) => PublicacionModel.fromMap(
              d.data() as Map<String, dynamic>,
              d.id,
            ))
        .toList();
  }
}
