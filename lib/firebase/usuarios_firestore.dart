import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_share/models/usuario_model.dart';

class UsuariosFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _col;

  UsuariosFirestore() {
    _col = _firestore.collection('usuarios');
  }

  // ── CRUD básico ───────────────────────────────────────────────────────────

  Future<bool> insertUsuario(Map<String, dynamic> data) async {
    try {
      await _col.doc(data['uid'] as String).set(data);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('insertUsuario error: $e');
      return false;
    }
  }

  Future<bool> updateUsuario(String uid, Map<String, dynamic> data) async {
    try {
      await _col.doc(uid).update(data);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('updateUsuario error: $e');
      return false;
    }
  }

  Future<UsuarioModel?> getUsuario(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('getUsuario error: $e');
      return null;
    }
  }

  Stream<UsuarioModel?> streamUsuario(String uid) {
    return _col.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UsuarioModel.fromMap(snap.data() as Map<String, dynamic>);
    });
  }

  // ── Búsqueda ──────────────────────────────────────────────────────────────

  Future<List<UsuarioModel>> buscarUsuarios(String query) async {
    try {
      final snap = await _col
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();
      return snap.docs
          .map((d) => UsuarioModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('buscarUsuarios error: $e');
      return [];
    }
  }

  /// Devuelve usuarios que comparten al menos un género con [generos].
  Future<List<UsuarioModel>> sugerenciasPorGenero(
    List<String> generos,
    String miUid,
  ) async {
    if (generos.isEmpty) return [];
    try {
      final snap = await _col
          .where('generosInteres', arrayContainsAny: generos)
          .limit(30)
          .get();
      return snap.docs
          .map((d) => UsuarioModel.fromMap(d.data() as Map<String, dynamic>))
          .where((u) => u.uid != miUid)
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('sugerenciasPorGenero error: $e');
      return [];
    }
  }

  // ── Solicitudes de amistad ────────────────────────────────────────────────

  Future<bool> enviarSolicitud(String miUid, String destinoUid) async {
    try {
      final batch = _firestore.batch();
      batch.update(_col.doc(miUid), {
        'solicitudesEnviadas': FieldValue.arrayUnion([destinoUid]),
      });
      batch.update(_col.doc(destinoUid), {
        'solicitudesRecibidas': FieldValue.arrayUnion([miUid]),
      });
      await batch.commit();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('enviarSolicitud error: $e');
      return false;
    }
  }

  Future<bool> aceptarSolicitud(String miUid, String origenUid) async {
    try {
      final batch = _firestore.batch();
      // Agregar como amigos mutuamente
      batch.update(_col.doc(miUid), {
        'amigos': FieldValue.arrayUnion([origenUid]),
        'solicitudesRecibidas': FieldValue.arrayRemove([origenUid]),
      });
      batch.update(_col.doc(origenUid), {
        'amigos': FieldValue.arrayUnion([miUid]),
        'solicitudesEnviadas': FieldValue.arrayRemove([miUid]),
      });
      await batch.commit();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('aceptarSolicitud error: $e');
      return false;
    }
  }

  Future<bool> rechazarSolicitud(String miUid, String origenUid) async {
    try {
      final batch = _firestore.batch();
      batch.update(_col.doc(miUid), {
        'solicitudesRecibidas': FieldValue.arrayRemove([origenUid]),
      });
      batch.update(_col.doc(origenUid), {
        'solicitudesEnviadas': FieldValue.arrayRemove([miUid]),
      });
      await batch.commit();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('rechazarSolicitud error: $e');
      return false;
    }
  }

  // ── Stream colección ──────────────────────────────────────────────────────

  Stream<QuerySnapshot> getUsuarios() => _col.snapshots();
}
