// lib/firebase/fcm_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Solicita permisos y guarda el token FCM en Firestore
  /// bajo usuarios/{uid}/fcmToken
  Future<void> inicializar(String uid) async {
    // Solicitar permisos (necesario en iOS, recomendado en Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener token actual
    final token = await _messaging.getToken();
    if (token != null) {
      await _guardarToken(uid, token);
    }

    // Escuchar renovaciones de token
    _messaging.onTokenRefresh.listen((nuevoToken) {
      _guardarToken(uid, nuevoToken);
    });
  }

  Future<void> _guardarToken(String uid, String token) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      print('FcmService._guardarToken error: $e');
    }
  }

  /// Llama esto al cerrar sesión para no recibir notificaciones de otro usuario
  Future<void> limpiarToken(String uid) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'fcmToken': null,
      });
      await _messaging.deleteToken();
    } catch (e) {
      print('FcmService.limpiarToken error: $e');
    }
  }
}