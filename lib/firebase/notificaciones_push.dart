import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NotificacionesPush {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/firebase.messaging',
    ],
  );

  final Dio _dio = Dio();

  static const String _projectId = 'vibeshare-ba9ce';

  static const String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  Future<String?> _getAccessToken() async {
    try {
      GoogleSignInAccount? user = _googleSignIn.currentUser;

      user ??= await _googleSignIn.signIn();

      if (user == null) {
        print('Usuario no autenticado');
        return null;
      }

      final GoogleSignInAuthentication auth =
          await user.authentication;

      return auth.accessToken;
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
      // Obtener documento del autor
      final doc =
          await _firestore.collection('usuarios').doc(autorUid).get();

      if (!doc.exists) {
        print('Usuario destino no encontrado');
        return;
      }

      final data = doc.data();

      final String? fcmToken = data?['fcmToken'];

      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM token vacío');
        return;
      }

      // Obtener access token
      final accessToken = await _getAccessToken();

      if (accessToken == null) {
        print('No se pudo obtener access token');
        return;
      }

      final response = await _dio.post(
        _fcmUrl,
        data: {
          'message': {
            'token': fcmToken,
            'notification': {
              'title': '❤️ Nuevo like',
              'body':
                  '$remitenteNombre le dio like a tu canción "$cancion"',
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

      print('Notificación enviada');
      print(response.data);
    } on DioException catch (e) {
      print(
        'notificarLike DioError: '
        '${e.response?.statusCode} '
        '${e.response?.data}',
      );
    } catch (e) {
      print('notificarLike error: $e');
    }
  }
}