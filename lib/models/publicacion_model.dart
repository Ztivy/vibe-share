enum TipoMedia { audio, video, ninguno }

class PublicacionModel {
  final String id;
  final String autorUid;
  final String autorNombre;
  final String autorAvatarUrl;
  final String descripcion;
  final String cancion;
  final String artista;
  final String genero;
  final String? mediaUrl;
  final TipoMedia tipoMedia;
  final List<String> likes;
  final int comentariosCount;
  final bool esPremium;
  final DateTime creadoEn;

  const PublicacionModel({
    required this.id,
    required this.autorUid,
    required this.autorNombre,
    required this.autorAvatarUrl,
    required this.descripcion,
    required this.cancion,
    required this.artista,
    required this.genero,
    this.mediaUrl,
    this.tipoMedia = TipoMedia.ninguno,
    this.likes = const [],
    this.comentariosCount = 0,
    this.esPremium = false,
    required this.creadoEn,
  });

  bool get tieneMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  int get likesCount => likes.length;
  bool tieneLike(String uid) => likes.contains(uid);

  factory PublicacionModel.fromMap(Map<String, dynamic> data, String id) {
    return PublicacionModel(
      id: id,
      autorUid: data['autorUid'] as String? ?? '',
      autorNombre: data['autorNombre'] as String? ?? '',
      autorAvatarUrl: data['autorAvatarUrl'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      cancion: data['cancion'] as String? ?? '',
      artista: data['artista'] as String? ?? '',
      genero: data['genero'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String?,
      tipoMedia: TipoMedia.values.firstWhere(
        (e) => e.name == (data['tipoMedia'] as String? ?? 'ninguno'),
        orElse: () => TipoMedia.ninguno,
      ),
      likes: List<String>.from(data['likes'] as List? ?? []),
      comentariosCount: data['comentariosCount'] as int? ?? 0,
      esPremium: data['esPremium'] as bool? ?? false,
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
      'descripcion': descripcion,
      'cancion': cancion,
      'artista': artista,
      'genero': genero,
      'mediaUrl': mediaUrl,
      'tipoMedia': tipoMedia.name,
      'likes': likes,
      'comentariosCount': comentariosCount,
      'esPremium': esPremium,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  PublicacionModel copyWith({
    String? id,
    String? autorUid,
    String? autorNombre,
    String? autorAvatarUrl,
    String? descripcion,
    String? cancion,
    String? artista,
    String? genero,
    String? mediaUrl,
    TipoMedia? tipoMedia,
    List<String>? likes,
    int? comentariosCount,
    bool? esPremium,
    DateTime? creadoEn,
  }) {
    return PublicacionModel(
      id: id ?? this.id,
      autorUid: autorUid ?? this.autorUid,
      autorNombre: autorNombre ?? this.autorNombre,
      autorAvatarUrl: autorAvatarUrl ?? this.autorAvatarUrl,
      descripcion: descripcion ?? this.descripcion,
      cancion: cancion ?? this.cancion,
      artista: artista ?? this.artista,
      genero: genero ?? this.genero,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      tipoMedia: tipoMedia ?? this.tipoMedia,
      likes: likes ?? this.likes,
      comentariosCount: comentariosCount ?? this.comentariosCount,
      esPremium: esPremium ?? this.esPremium,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicacionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
