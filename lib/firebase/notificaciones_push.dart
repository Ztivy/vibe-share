import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class NotificacionesPush {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Dio _dio = Dio();

  static const _projectId = 'vibeshare-ba9ce';
  static const _serviceAccountAssetPath =
      'assets/vibeshare-claveRol.json';
  static const _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  static const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  Future<String?> _getAccessToken() async {
    try {
      final jsonStr = await rootBundle.loadString(_serviceAccountAssetPath);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final accountCredentials = ServiceAccountCredentials.fromJson(json);
      final client = await clientViaServiceAccount(accountCredentials, _scopes);
      final token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (e) {
      debugPrint('_getAccessToken error: $e');
      return null;
    }
  }

  Future<void> notificarLike({
    required String autorUid,
    required String remitenteNombre,
    required String cancion,
  }) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(autorUid).get();
      if (!doc.exists) return;

      final fcmToken = doc.data()?['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      final accessToken = await _getAccessToken();
      if (accessToken == null) return;

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
      debugPrint('notificarLike DioError: ${e.response?.statusCode} ${e.response?.data}');
    } catch (e) {
      debugPrint('notificarLike error: $e');
    }
  }
}