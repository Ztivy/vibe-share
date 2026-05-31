// lib/firebase/storage_supabase.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageSupabase {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _bucketAvatars = 'avatars';
  static const String _bucketMedia = 'publicaciones-media';

  // ── Avatar ────────────────────────────────────────────────────────────────

  /// Sube o reemplaza el avatar de un usuario.
  /// Devuelve la URL pública o null si falla.
  Future<String?> subirAvatar(String uid, File file) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final path = '$uid/avatar.$ext';

      await _client.storage.from(_bucketAvatars).upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = _client.storage.from(_bucketAvatars).getPublicUrl(path);
      // Añadir cache-buster para forzar recarga
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      // ignore: avoid_print
      print('subirAvatar error: $e');
      return null;
    }
  }

  /// Elimina el avatar de un usuario.
  Future<bool> eliminarAvatar(String uid, String ext) async {
    try {
      await _client.storage
          .from(_bucketAvatars)
          .remove(['$uid/avatar.$ext']);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('eliminarAvatar error: $e');
      return false;
    }
  }

  // ── Media de publicaciones ────────────────────────────────────────────────

  /// Sube un archivo de audio o video para una publicación.
  /// [publicacionId] es el ID previo del documento de Firestore.
  /// Devuelve la URL pública o null si falla.
  Future<String?> subirMedia(
    String publicacionId,
    File file, {
    required String tipo, // 'audio' | 'video'
  }) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final path = '$publicacionId/$tipo.$ext';

      await _client.storage.from(_bucketMedia).upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      return _client.storage.from(_bucketMedia).getPublicUrl(path);
    } catch (e) {
      // ignore: avoid_print
      print('subirMedia error: $e');
      return null;
    }
  }

  /// Elimina todos los archivos de una publicación.
  Future<bool> eliminarMedia(String publicacionId) async {
    try {
      final lista = await _client.storage
          .from(_bucketMedia)
          .list(path: publicacionId);

      if (lista.isEmpty) return true;

      final paths = lista.map((f) => '$publicacionId/${f.name}').toList();
      await _client.storage.from(_bucketMedia).remove(paths);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('eliminarMedia error: $e');
      return false;
    }
  }
}
