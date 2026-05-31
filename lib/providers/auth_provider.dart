import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_share/firebase/auth_google.dart';
import 'package:vibe_share/firebase/usuarios_firestore.dart';
import 'package:vibe_share/models/usuario_model.dart';
//import 'package:vibe_share/utils/strings_app.dart';

class AuthProvider extends ChangeNotifier {
  final AuthGoogle _authGoogle = AuthGoogle();
  final UsuariosFirestore _usuariosFirestore = UsuariosFirestore();

  bool isDarkMode = false;
  bool isLoading = false;
  UsuarioModel? usuarioActual;

  AuthProvider() {
    _authGoogle.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      final doc = await _usuariosFirestore.getUsuario(user.uid);
      usuarioActual = doc ?? UsuarioModel(
        uid: user.uid,
        nombre: user.displayName ?? '',
        email: user.email ?? '',
        avatarUrl: user.photoURL ?? '',
        //?? StringsApp.defaultAvatar,
      );
    } else {
      usuarioActual = null;
    }
    notifyListeners();
  }

  Future<bool> loginConGoogle() async {
    isLoading = true;
    notifyListeners();

    final user = await _authGoogle.signInWithGoogle();

    if (user != null) {
      final existente = await _usuariosFirestore.getUsuario(user.uid);
      if (existente == null) {
        await _usuariosFirestore.insertUsuario(
          UsuarioModel(
            uid: user.uid,
            nombre: user.displayName ?? '',
            email: user.email ?? '',
            avatarUrl: user.photoURL ?? '',
            //?? StringsApp.defaultAvatar,
          ).toMap(),
        );
      }
      isLoading = false;
      notifyListeners();
      return true;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authGoogle.signOut();
    usuarioActual = null;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}