import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_share/models/usuario_model.dart';

class BuscarUsuariosResultado {
  final List<UsuarioModel> usuarios;
  final String? error;

  BuscarUsuariosResultado({required this.usuarios, this.error});
}

class UsuariosFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _col;

  UsuariosFirestore() {
    _col = _firestore.collection('usuarios');
  }

  // ── CRUD básico ───────────────────────────────────────────────────────────

  Future<bool> insertUsuario(Map<String, dynamic> data) async {
    try {
      final dataToInsert = Map<String, dynamic>.from(data);
      if (dataToInsert['nombre'] != null && dataToInsert['nombreLower'] == null) {
        dataToInsert['nombreLower'] = dataToInsert['nombre'].toString().toLowerCase();
      }
      await _col.doc(dataToInsert['uid'] as String).set(dataToInsert);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('insertUsuario error: $e');
      return false;
    }
  }

  Future<bool> updateUsuario(String uid, Map<String, dynamic> data) async {
    try {
      final dataToUpdate = Map<String, dynamic>.from(data);
      if (dataToUpdate['nombre'] != null) {
        dataToUpdate['nombreLower'] = dataToUpdate['nombre'].toString().toLowerCase();
      }
      await _col.doc(uid).update(dataToUpdate);
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

  Future<BuscarUsuariosResultado> buscarUsuariosConEstado(String query) async {
    if (query.trim().isEmpty) {
      return BuscarUsuariosResultado(usuarios: []);
    }

    try {
      final usuarios = await buscarUsuarios(query);
      return BuscarUsuariosResultado(usuarios: usuarios);
    } catch (e) {
      return BuscarUsuariosResultado(
        usuarios: [],
        error: 'Error al buscar usuarios: $e',
      );
    }
  }

  Future<List<UsuarioModel>> buscarUsuarios(String query) async {
    if (query.trim().isEmpty) return [];
    try {
    final q = query.trim();
    final qLower = q.toLowerCase();
    final qCapital = q[0].toUpperCase() + (q.length > 1 ? q.substring(1).toLowerCase() : '');

    final futures = await Future.wait([
      _col
          .where('nombre', isGreaterThanOrEqualTo: q)
          .where('nombre', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(10)
          .get(),
      _col
          .where('nombre', isGreaterThanOrEqualTo: qCapital)
          .where('nombre', isLessThanOrEqualTo: '$qCapital\uf8ff')
          .limit(10)
          .get(),
      _col
          .where('nombre', isGreaterThanOrEqualTo: qLower)
          .where('nombre', isLessThanOrEqualTo: '$qLower\uf8ff')
          .limit(10)
          .get(),
      // ← aquí va el fragmento que preguntabas
      _col
          .where('nombreLower', isGreaterThanOrEqualTo: qLower)
          .where('nombreLower', isLessThanOrEqualTo: '$qLower\uf8ff')
          .limit(10)
          .get(),
    ]);

    final Map<String, UsuarioModel> vistos = {};
    for (final snap in futures) {
      for (final d in snap.docs) {
        final u = UsuarioModel.fromMap(d.data() as Map<String, dynamic>);
        vistos[u.uid] = u;
      }
    }
    return vistos.values.toList();
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
