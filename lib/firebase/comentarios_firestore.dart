// lib/firebase/comentarios_firestore.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_share/models/comentario_model.dart';

class ComentariosFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Subcolección: publicaciones/{publicacionId}/comentarios
  CollectionReference _col(String publicacionId) => _firestore
      .collection('publicaciones')
      .doc(publicacionId)
      .collection('comentarios');

  /// Stream en tiempo real de comentarios de una publicación
  Stream<List<ComentarioModel>> streamComentarios(String publicacionId) {
    return _col(publicacionId)
        .orderBy('creadoEn', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ComentarioModel.fromMap(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ))
            .toList());
  }

  /// Agrega un comentario y actualiza el contador en la publicación
  Future<bool> agregarComentario({
    required String publicacionId,
    required ComentarioModel comentario,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Agregar el comentario a la subcolección
      final comentarioRef = _col(publicacionId).doc();
      batch.set(comentarioRef, comentario.toMap());

      // 2. Incrementar contador en la publicación
      final pubRef =
          _firestore.collection('publicaciones').doc(publicacionId);
      batch.update(pubRef, {
        'comentariosCount': FieldValue.increment(1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('agregarComentario error: $e');
      return false;
    }
  }

  /// Elimina un comentario y decrementa el contador
  Future<bool> eliminarComentario({
    required String publicacionId,
    required String comentarioId,
  }) async {
    try {
      final batch = _firestore.batch();

      batch.delete(_col(publicacionId).doc(comentarioId));

      final pubRef =
          _firestore.collection('publicaciones').doc(publicacionId);
      batch.update(pubRef, {
        'comentariosCount': FieldValue.increment(-1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('eliminarComentario error: $e');
      return false;
    }
  }
}