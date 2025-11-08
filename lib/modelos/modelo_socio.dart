class ModeloSocio {
  String? uid;
  String nombre;
  String apellido;
  int dni;
  String rol;
  String email;

  ModeloSocio({
    this.uid,
    required this.nombre,
    required this.apellido,
  required this.dni,
    this.rol = 'socio',
    required this.email,
  });

  factory ModeloSocio.fromMap(Map<String, dynamic> m) {
    return ModeloSocio(
      uid: m['uid']?.toString(),
      nombre: (m['nombre'] ?? '') as String,
      apellido: (m['apellido'] ?? '') as String,
    // `dni` puede venir como int (desde Firestore) o como String; normalizamos a int
    dni: m['dni'] is int
      ? m['dni'] as int
      : int.tryParse((m['dni'] ?? '').toString()) ?? 0,
      rol: (m['rol'] ?? 'socio') as String,
      email: (m['email'] ?? '') as String,
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
    };
  }
}
