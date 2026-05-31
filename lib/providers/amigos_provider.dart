import 'package:flutter/material.dart';
import 'package:vibe_share/firebase/usuarios_firestore.dart';
import 'package:vibe_share/models/usuario_model.dart';

class AmigosProvider extends ChangeNotifier {
  final UsuariosFirestore _firestore = UsuariosFirestore();

  bool isLoading = false;
  String? error;

  List<UsuarioModel> resultadosBusqueda = [];
  List<UsuarioModel> sugerencias = [];

  // ── Buscar ────────────────────────────────────────────────────────────────

  Future<void> buscar(String query) async {
    if (query.trim().isEmpty) {
      resultadosBusqueda = [];
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();

    resultadosBusqueda = await _firestore.buscarUsuarios(query.trim());
    isLoading = false;
    notifyListeners();
  }

  // ── Sugerencias por género ────────────────────────────────────────────────

  Future<void> cargarSugerencias(
    List<String> generos,
    String miUid,
  ) async {
    sugerencias =
        await _firestore.sugerenciasPorGenero(generos, miUid);
    notifyListeners();
  }

  // ── Solicitudes ───────────────────────────────────────────────────────────

  Future<bool> enviarSolicitud(String miUid, String destinoUid) async {
    final ok = await _firestore.enviarSolicitud(miUid, destinoUid);
    return ok;
  }

  Future<bool> aceptarSolicitud(String miUid, String origenUid) async {
    final ok = await _firestore.aceptarSolicitud(miUid, origenUid);
    return ok;
  }

  Future<bool> rechazarSolicitud(String miUid, String origenUid) async {
    final ok = await _firestore.rechazarSolicitud(miUid, origenUid);
    return ok;
  }
}