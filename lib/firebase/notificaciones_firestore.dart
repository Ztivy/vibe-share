import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionesFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _col;

  NotificacionesFirestore() {
    _col = _firestore.collection('notificaciones');
  }

  Future<void> crearNotificacion({
    required String destinoUid,
    required String origenUid,
    required String origenNombre,
    required String origenAvatar,
    required String tipo, // 'solicitud_amistad' | 'like' | 'nueva_publicacion'
    String? extra,
  }) async {
    try {
      await _col.add({
        'destinoUid': destinoUid,
        'origenUid': origenUid,
        'origenNombre': origenNombre,
        'origenAvatar': origenAvatar,
        'tipo': tipo,
        'extra': extra ?? '',
        'leida': false,
        'creadoEn': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('crearNotificacion error: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamNotificaciones(String uid) {
    return _col
        .where('destinoUid', isEqualTo: uid)
        .limit(30)
        .snapshots()
        .map((snap) {
      final lista = snap.docs
          .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
          .toList();
      lista.sort((a, b) {
        final aDate = DateTime.tryParse(a['creadoEn'] ?? '') ?? DateTime(0);
        final bDate = DateTime.tryParse(b['creadoEn'] ?? '') ?? DateTime(0);
        return bDate.compareTo(aDate);
      });
      return lista;
    });
  }

  Stream<int> streamNoLeidas(String uid) {
    return _col
        .where('destinoUid', isEqualTo: uid)
        .where('leida', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> marcarLeida(String notifId) async {
    try {
      await _col.doc(notifId).update({'leida': true});
    } catch (e) {
      // ignore: avoid_print
      print('marcarLeida error: $e');
    }
  }

  Future<void> marcarTodasLeidas(String uid) async {
    try {
      final snap = await _col
          .where('destinoUid', isEqualTo: uid)
          .where('leida', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final d in snap.docs) {
        batch.update(d.reference, {'leida': true});
      }
      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('marcarTodasLeidas error: $e');
    }
  }
}