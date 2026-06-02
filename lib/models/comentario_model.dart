// lib/models/comentario_model.dart

class ComentarioModel {
  final String id;
  final String autorUid;
  final String autorNombre;
  final String autorAvatarUrl;
  final String texto;
  final DateTime creadoEn;

  const ComentarioModel({
    required this.id,
    required this.autorUid,
    required this.autorNombre,
    required this.autorAvatarUrl,
    required this.texto,
    required this.creadoEn,
  });

  factory ComentarioModel.fromMap(Map<String, dynamic> data, String id) {
    return ComentarioModel(
      id: id,
      autorUid: data['autorUid'] as String? ?? '',
      autorNombre: data['autorNombre'] as String? ?? '',
      autorAvatarUrl: data['autorAvatarUrl'] as String? ?? '',
      texto: data['texto'] as String? ?? '',
      creadoEn: data['creadoEn'] != null
          ? DateTime.parse(data['creadoEn'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autorUid': autorUid,
      'autorNombre': autorNombre,
      'autorAvatarUrl': autorAvatarUrl,
      'texto': texto,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }
}