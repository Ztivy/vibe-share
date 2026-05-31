class UsuarioModel {
  final String uid;
  final String nombre;
  final String email;
  final String avatarUrl;
  final List<String> generosInteres;
  final List<String> amigos;
  final bool esPremium;

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.avatarUrl,
    this.generosInteres = const [],
    this.amigos = const [],
    this.esPremium = false,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> data) {
    return UsuarioModel(
      uid: data['uid'] ?? '',
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      generosInteres: List<String>.from(data['generosInteres'] ?? []),
      amigos: List<String>.from(data['amigos'] ?? []),
      esPremium: data['esPremium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'avatarUrl': avatarUrl,
      'generosInteres': generosInteres,
      'amigos': amigos,
      'esPremium': esPremium,
    };
  }
}