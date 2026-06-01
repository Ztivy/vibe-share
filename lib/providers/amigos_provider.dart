import 'package:flutter/material.dart';
import 'package:vibe_share/firebase/notificaciones_firestore.dart';
import 'package:vibe_share/firebase/usuarios_firestore.dart';
import 'package:vibe_share/models/usuario_model.dart';

class AmigosProvider extends ChangeNotifier {
  final UsuariosFirestore _firestore = UsuariosFirestore();
  final NotificacionesFirestore _notifs = NotificacionesFirestore();

  bool isLoading = false;
  String? errorBusqueda;
  List<UsuarioModel> resultadosBusqueda = [];
  List<UsuarioModel> sugerencias = [];

  // ── Buscar ────────────────────────────────────────────────────────────────

  Future<void> buscar(String query) async {
    if (query.trim().isEmpty) {
      resultadosBusqueda = [];
      errorBusqueda = null;
      notifyListeners();
      return;
    }
    isLoading = true;
    errorBusqueda = null;
    notifyListeners();

    final resultado = await _firestore.buscarUsuariosConEstado(query.trim());
    resultadosBusqueda = resultado.usuarios;
    errorBusqueda = resultado.error;
    isLoading = false;
    notifyListeners();
  }

  Future<void> cargarSugerencias(List<String> generos, String miUid) async {
    sugerencias = await _firestore.sugerenciasPorGenero(generos, miUid);
    notifyListeners();
  }

  // ── Solicitudes ───────────────────────────────────────────────────────────

  Future<bool> enviarSolicitud(
    String miUid,
    String destinoUid, {
    required String miNombre,
    required String miAvatar,
  }) async {
    final ok = await _firestore.enviarSolicitud(miUid, destinoUid);
    if (ok) {
      await _notifs.crearNotificacion(
        destinoUid: destinoUid,
        origenUid: miUid,
        origenNombre: miNombre,
        origenAvatar: miAvatar,
        tipo: 'solicitud_amistad',
      );
    }
    return ok;
  }

  Future<bool> aceptarSolicitud(
    String miUid,
    String origenUid, {
    String miNombre = '',
    String miAvatar = '',
  }) async {
    final ok = await _firestore.aceptarSolicitud(miUid, origenUid);
    if (ok && miNombre.isNotEmpty) {
      await _notifs.crearNotificacion(
        destinoUid: origenUid,
        origenUid: miUid,
        origenNombre: miNombre,
        origenAvatar: miAvatar,
        tipo: 'solicitud_aceptada',
      );
    }
    return ok;
  }

  Future<bool> rechazarSolicitud(String miUid, String origenUid) async {
    final ok = await _firestore.rechazarSolicitud(miUid, origenUid);
    return ok;
  }
}