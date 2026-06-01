import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_share/firebase/auth_google.dart';
import 'package:vibe_share/firebase/publicaciones_firestore.dart';
import 'package:vibe_share/firebase/usuarios_firestore.dart';
import 'package:vibe_share/models/usuario_model.dart';
import 'package:vibe_share/utils/strings_app.dart';

class AuthProvider extends ChangeNotifier {
  final AuthGoogle _authGoogle = AuthGoogle();
  final UsuariosFirestore _usuariosFirestore = UsuariosFirestore();
  final PublicacionesFirestore _publicacionesFirestore = PublicacionesFirestore();

  bool isDarkMode = false;
  bool isLoading = false;
  String? error;
  UsuarioModel? usuarioActual;

  AuthProvider() {
    _authGoogle.authStateChanges.listen(_onAuthStateChanged);
  }

  bool get isAuthenticated => usuarioActual != null;

  // ── Auth state ────────────────────────────────────────────────────────────

  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      final doc = await _usuariosFirestore.getUsuario(user.uid);
      usuarioActual = doc ??
          UsuarioModel(
            uid: user.uid,
            nombre: user.displayName ?? '',
            email: user.email ?? '',
            avatarUrl: user.photoURL ?? StringsApp.defaultAvatar,
            creadoEn: DateTime.now(),
          );
    } else {
      usuarioActual = null;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> loginConGoogle() async {
    error = null;
    isLoading = true;
    notifyListeners();

    try {
      final user = await _authGoogle.signInWithGoogle();

      if (user != null) {
        final existente = await _usuariosFirestore.getUsuario(user.uid);
        if (existente == null) {
          final nuevo = UsuarioModel(
            uid: user.uid,
            nombre: user.displayName ?? '',
            email: user.email ?? '',
            avatarUrl: user.photoURL ?? StringsApp.defaultAvatar,
            creadoEn: DateTime.now(),
          );
          await _usuariosFirestore.insertUsuario(nuevo.toMap());
        } else {
          usuarioActual = existente;
          await _usuariosFirestore.updateUsuario(
            user.uid,
            {'nombreLower': existente.nombre.toLowerCase()},
          );
        }
        isLoading = false;
        notifyListeners();
        return true;
      }

      error = StringsApp.loginError;
    } catch (e) {
      error = StringsApp.errorGeneral;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authGoogle.signOut();
    usuarioActual = null;
    notifyListeners();
  }

  // ── Perfil ────────────────────────────────────────────────────────────────

  Future<bool> actualizarPerfil(Map<String, dynamic> data) async {
    if (usuarioActual == null) return false;
    final dataToUpdate = Map<String, dynamic>.from(data);
    final cambiarNombre = dataToUpdate.containsKey('nombre');
    if (cambiarNombre) {
      dataToUpdate['nombreLower'] = dataToUpdate['nombre'].toString().toLowerCase();
    }
    final ok = await _usuariosFirestore.updateUsuario(usuarioActual!.uid, dataToUpdate);
    if (ok) {
      if (cambiarNombre) {
        await _publicacionesFirestore.actualizarAutorNombre(
          usuarioActual!.uid,
          dataToUpdate['nombre'].toString(),
        );
      }
      usuarioActual = UsuarioModel.fromMap({
        ...usuarioActual!.toMap(),
        ...dataToUpdate,
      });
      notifyListeners();
    }
    return ok;
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // ── Refrescar usuario desde Firestore ────────────────────────────────────

Future<void> refrescarUsuario() async {
  if (usuarioActual == null) return;
  final doc = await _usuariosFirestore.getUsuario(usuarioActual!.uid);
  if (doc != null) {
    usuarioActual = doc;
    notifyListeners();
  }
}

// ── Obtener usuario por UID (para tiles de solicitudes) ──────────────────

Future<UsuarioModel?> getUsuarioPorUid(String uid) async {
  return await _usuariosFirestore.getUsuario(uid);
}
}
