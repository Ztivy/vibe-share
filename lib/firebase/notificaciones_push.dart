// lib/firebase/notificaciones_push.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NotificacionesPush {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final Dio _dio = Dio();

  static const _projectId = 'vibeshare-ba9ce';
  static const _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  Future<String?> _getAccessToken() async {
    try {
      // Reutiliza la sesión activa igual que en AuthGoogle
      final googleUser = await _googleSignIn.authenticate();
      final clientAuth = await googleUser.authorizationClient
          .authorizeScopes([
        'https://www.googleapis.com/auth/firebase.messaging',
      ]);
      return clientAuth.accessToken;
    } catch (e) {
      print('_getAccessToken error: $e');
      return null;
    }
  }

  Future<void> notificarLike({
    required String autorUid,
    required String remitenteNombre,
    required String cancion,
  }) async {
    try {
      // 1. Token FCM del autor
      final doc =
          await _firestore.collection('usuarios').doc(autorUid).get();
      if (!doc.exists) return;

      final fcmToken = doc.data()?['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      // 2. Access Token OAuth2
      final accessToken = await _getAccessToken();
      if (accessToken == null) return;

      // 3. Enviar via FCM HTTP v1
      await _dio.post(
        _fcmUrl,
        data: {
          'message': {
            'token': fcmToken,
            'notification': {
              'title': '❤️ Nuevo like',
              'body': '$remitenteNombre le dio like a tu canción "$cancion"',
            },
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'likes',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              },
            },
            'data': {
              'tipo': 'like',
              'autorUid': autorUid,
            },
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      print('notificarLike DioError: ${e.response?.statusCode} ${e.response?.data}');
    } catch (e) {
      print('notificarLike error: $e');
    }
  }
}