import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_share/models/usuario_model.dart';

class UsuariosFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _usuariosCollection;

  UsuariosFirestore() {
    _usuariosCollection = _firestore.collection('usuarios');
  }

  Future<bool> insertUsuario(Map<String, dynamic> data) async {
    try {
      await _usuariosCollection!.doc(data['uid']).set(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateUsuario(String uid, Map<String, dynamic> data) async {
    try {
      await _usuariosCollection!.doc(uid).update(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UsuarioModel?> getUsuario(String uid) async {
    try {
      final doc = await _usuariosCollection!.doc(uid).get();
      if (!doc.exists) return null;
      return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot> getUsuarios() {
    return _usuariosCollection!.snapshots();
  }
}