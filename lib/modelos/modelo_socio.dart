class ModeloSocio {
  String? uid;
  String nombre;
  String apellido;
  int dni;
  String rol;
  String email;
  String? fotoUrl;
  String? fotoBase64;
  String? estadoCuota; // NUEVO: "activo", "deudor"
  String? ultimaCuotaPagada; // NUEVO: "noviembre", "diciembre", etc.

  ModeloSocio({
    this.uid,
    required this.nombre,
    required this.apellido,
    required this.dni,
    this.rol = 'socio',
    required this.email,
    this.fotoUrl,
    this.fotoBase64,
    this.estadoCuota,
    this.ultimaCuotaPagada,
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
      estadoCuota: (m['estado_cuota'] as String?) ?? 'deudor',
      ultimaCuotaPagada: (m['ultima_cuota_pagada'] as String?),
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
      'estado_cuota': estadoCuota ?? 'deudor',
      if (ultimaCuotaPagada != null) 'ultima_cuota_pagada': ultimaCuotaPagada,
    };
  }
}
