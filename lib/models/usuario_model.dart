class UsuarioModel {
  final String uid;
  final String nombre;
  final String email;
  final String avatarUrl;
  final String bio;
  final List<String> generosInteres;
  final List<String> amigos;
  final List<String> solicitudesEnviadas;
  final List<String> solicitudesRecibidas;
  final bool esPremium;
  final DateTime? creadoEn;

  const UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.avatarUrl,
    this.bio = '',
    this.generosInteres = const [],
    this.amigos = const [],
    this.solicitudesEnviadas = const [],
    this.solicitudesRecibidas = const [],
    this.esPremium = false,
    this.creadoEn,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> data) {
    return UsuarioModel(
      uid: data['uid'] as String? ?? '',
      nombre: data['nombre'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      generosInteres: List<String>.from(data['generosInteres'] as List? ?? []),
      amigos: List<String>.from(data['amigos'] as List? ?? []),
      solicitudesEnviadas:
          List<String>.from(data['solicitudesEnviadas'] as List? ?? []),
      solicitudesRecibidas:
          List<String>.from(data['solicitudesRecibidas'] as List? ?? []),
      esPremium: data['esPremium'] as bool? ?? false,
      creadoEn: data['creadoEn'] != null
          ? DateTime.tryParse(data['creadoEn'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'nombreLower': nombre.toLowerCase(),
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'generosInteres': generosInteres,
      'amigos': amigos,
      'solicitudesEnviadas': solicitudesEnviadas,
      'solicitudesRecibidas': solicitudesRecibidas,
      'esPremium': esPremium,
      'creadoEn': creadoEn?.toIso8601String(),
    };
  }

  UsuarioModel copyWith({
    String? uid,
    String? nombre,
    String? email,
    String? avatarUrl,
    String? bio,
    List<String>? generosInteres,
    List<String>? amigos,
    List<String>? solicitudesEnviadas,
    List<String>? solicitudesRecibidas,
    bool? esPremium,
    DateTime? creadoEn,
  }) {
    return UsuarioModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      generosInteres: generosInteres ?? this.generosInteres,
      amigos: amigos ?? this.amigos,
      solicitudesEnviadas: solicitudesEnviadas ?? this.solicitudesEnviadas,
      solicitudesRecibidas: solicitudesRecibidas ?? this.solicitudesRecibidas,
      esPremium: esPremium ?? this.esPremium,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() =>
      'UsuarioModel(uid: $uid, nombre: $nombre, email: $email)';
}
