class ModeloSocio {
  String? uid;
  String nombre;
  String apellido;
  int dni;
  String rol;
  String email;
  String? fotoUrl;
  String? fotoBase64;

  ModeloSocio({
    this.uid,
    required this.nombre,
    required this.apellido,
    required this.dni,
    this.rol = 'socio',
    required this.email,
    this.fotoUrl,
    this.fotoBase64,
  });

  factory ModeloSocio.fromMap(Map<String, dynamic> m) {
    return ModeloSocio(
      uid: m['uid']?.toString(),
      nombre: (m['nombre'] ?? '') as String,
      apellido: (m['apellido'] ?? '') as String,
      dni: m['dni'] is int
        ? m['dni'] as int
        : int.tryParse((m['dni'] ?? '').toString()) ?? 0,
      rol: (m['rol'] ?? 'socio') as String,
      email: (m['email'] ?? '') as String,
      fotoUrl: (m['fotoUrl'] as String?) ?? '',
      fotoBase64: (m['fotoBase64'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'rol': rol,
      'email': email,
      'uid': uid,
      if (fotoUrl != null && fotoUrl!.isNotEmpty) 'fotoUrl': fotoUrl,
      if (fotoBase64 != null && fotoBase64!.isNotEmpty) 'fotoBase64': fotoBase64,
    };
  }
}
