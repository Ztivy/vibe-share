import 'package:dio/dio.dart';

class DeezerTrack {
  final int id;
  final String titulo;
  final String artista;
  final String previewUrl;
  final String? albumCover;

  DeezerTrack({
    required this.id,
    required this.titulo,
    required this.artista,
    required this.previewUrl,
    this.albumCover,
  });

  factory DeezerTrack.fromMap(Map<String, dynamic> data) {
    return DeezerTrack(
      id: data['id'] as int,
      titulo: data['title'] as String? ?? '',
      artista: (data['artist'] as Map?)?['name'] as String? ?? '',
      previewUrl: data['preview'] as String? ?? '',
      albumCover: (data['album'] as Map?)?['cover_medium'] as String?,
    );
  }
}

class DeezerApi {
  final Dio _dio = Dio();
  static const String _base = 'https://api.deezer.com';

  Future<List<DeezerTrack>> buscar(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final res = await _dio.get(
        '$_base/search',
        queryParameters: {'q': query, 'limit': 10},
      );
      final data = res.data['data'] as List? ?? [];
      return data
          .map((t) => DeezerTrack.fromMap(t as Map<String, dynamic>))
          .where((t) => t.previewUrl.isNotEmpty)
          .toList();
    } catch (e) {
      print('DeezerApi error: $e');
      return [];
    }
  }
}