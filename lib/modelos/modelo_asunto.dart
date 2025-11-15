import 'package:cloud_firestore/cloud_firestore.dart';

class ModeloAsunto {
  String? id;
  String? uidSocio;
  String nombre;
  String apellido;
  String email;
  String asunto;
  String descripcion;
  Timestamp fecha;
  bool leido;
  String? fotoBase64;
  String? respuesta;
  Timestamp? fechaRespuesta;
  bool respondido;

  ModeloAsunto({
    this.id,
    this.uidSocio,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.asunto,
    required this.descripcion,
    Timestamp? fecha,
    this.leido = false,
    this.fotoBase64,
    this.respuesta,
    this.fechaRespuesta,
    this.respondido = false,
  }) : fecha = fecha ?? Timestamp.now();

  Map<String, dynamic> toMap() => {
        'uidSocio': uidSocio,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'asunto': asunto,
        'descripcion': descripcion,
        'fecha': fecha,
        'leido': leido,
        if (fotoBase64 != null && fotoBase64!.isNotEmpty) 'fotoBase64': fotoBase64,
        if (respuesta != null) 'respuesta': respuesta,
        if (fechaRespuesta != null) 'fechaRespuesta': fechaRespuesta,
        'respondido': respondido,
      };

  static ModeloAsunto fromMap(Map<String, dynamic> map) {
    return ModeloAsunto(
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      email: map['email'] ?? '',
      asunto: map['asunto'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fecha: map['fecha'] is Timestamp ? map['fecha'] as Timestamp : Timestamp.now(),
      leido: map['leido'] ?? false,
      fotoBase64: map['fotoBase64'] as String?,
      respuesta: map['respuesta'] as String?,
      fechaRespuesta: map['fechaRespuesta'] is Timestamp ? map['fechaRespuesta'] as Timestamp : null,
      respondido: map['respondido'] ?? false,
    )..id = map['id'] ?? map['uid'];
  }
}
