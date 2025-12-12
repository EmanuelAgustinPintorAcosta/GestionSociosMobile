import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/modelo_socio.dart';
import '../modelos/modelo_evento.dart';
import '../modelos/modelo_asunto.dart';
import '../modelos/modelo_cuota.dart';

class DBServicio {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<ModeloSocio>> streamSocios() {
    return _db.collection('usuarios').snapshots().map((snap) =>
        snap.docs.map((d) => ModeloSocio.fromMap(d.data()..['uid'] = d.id)).toList());
  }

  static Future<Map<String, dynamic>?> obtenerSocio(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.data();
  }

  static Future<void> crearSocio(ModeloSocio s) async {
    if (s.uid != null && s.uid!.isNotEmpty) {
      await _db.collection('usuarios').doc(s.uid).set(s.toMap());
    } else {
      await _db.collection('usuarios').add(s.toMap());
    }
  }

  static Future<void> actualizarSocio(ModeloSocio s) async {
    if (s.uid == null) throw Exception('Socio sin uid');
    await _db.collection('usuarios').doc(s.uid).update(s.toMap());
  }

  static Future<void> actualizarFotoPerfil(String uid, String fotoUrl) async {
    await _db.collection('usuarios').doc(uid).update({'fotoUrl': fotoUrl});
  }

  static Future<void> actualizarFotoBase64(String uid, String fotoBase64) async {
    await _db.collection('usuarios').doc(uid).update({'fotoBase64': fotoBase64});
  }

  static Future<void> eliminarSocio(String uid) async {
    await _db.collection('usuarios').doc(uid).delete();
  }

  static Stream<List<ModeloEvento>> streamEventos() {
    return _db.collection('eventos').orderBy('fecha', descending: false).snapshots().map(
        (snap) => snap.docs.map((d) => ModeloEvento.fromMap(d.data()..['id'] = d.id)).toList());
  }

  static Future<void> crearEvento(ModeloEvento e) async {
    if (e.id != null && e.id!.isNotEmpty) {
      await _db.collection('eventos').doc(e.id).set(e.toMap());
    } else {
      await _db.collection('eventos').add(e.toMap());
    }
  }

  static Future<void> actualizarEvento(ModeloEvento e) async {
    if (e.id == null) throw Exception('Evento sin id');
    await _db.collection('eventos').doc(e.id).update(e.toMap());
  }

  static Future<void> eliminarEvento(String id) async {
    await _db.collection('eventos').doc(id).delete();
  }


  static Stream<List<ModeloAsunto>> streamAsuntos() {
    return _db.collection('asuntos').orderBy('fecha', descending: true).snapshots().map(
        (snap) => snap.docs
            .map((d) => ModeloAsunto.fromMap(d.data()..['id'] = d.id))
            .toList());
  }

  static Future<void> crearAsunto(ModeloAsunto a) async {
    if (a.id != null && a.id!.isNotEmpty) {
      await _db.collection('asuntos').doc(a.id).set(a.toMap());
    } else {
      await _db.collection('asuntos').add(a.toMap());
    }
  }

  static Future<void> eliminarAsunto(String id) async {
    await _db.collection('asuntos').doc(id).delete();
  }

  static Future<void> marcarLeido(String id, bool leido) async {
    await _db.collection('asuntos').doc(id).update({'leido': leido});
  }

  // Métodos para responder asuntos
  static Future<void> responderAsunto(String id, String respuesta) async {
    await _db.collection('asuntos').doc(id).update({
      'respuesta': respuesta,
      'fechaRespuesta': Timestamp.now(),
      'respondido': true,
    });
  }

  static Stream<List<ModeloAsunto>> streamAsuntosPorSocio(String uid) {
    return _db
        .collection('asuntos')
        .where('uidSocio', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ModeloAsunto.fromMap(d.data()..['id'] = d.id))
            .toList());
  }

  // ==================== MÉTODOS PARA CUOTAS ====================
  
  static Stream<List<ModeloCuota>> streamCuotasPorSocio(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('cuotas')
        .snapshots()
        .map((snap) {
          final docs = snap.docs
              .map((d) => ModeloCuota.fromMap(d.data(), d.id))
              .toList();
          // Ordenar por año ascendente, luego por mes ascendente (más próximas primero)
          docs.sort((a, b) {
            // Comparar años en orden ascendente
            int yearCompare = a.anio.compareTo(b.anio);
            if (yearCompare != 0) return yearCompare;
            // Si mismo año, ordenar meses ascendentes
            return int.parse(a.mes).compareTo(int.parse(b.mes));
          });
          return docs;
        });
  }

  static Future<ModeloCuota?> obtenerCuota(String uid, String mes) async {
    final doc = await _db
        .collection('usuarios')
        .doc(uid)
        .collection('cuotas')
        .doc(mes)
        .get();
    if (!doc.exists) return null;
    return ModeloCuota.fromMap(doc.data()!, doc.id);
  }

  static Future<void> actualizarCuota(String uid, String mes, Map<String, dynamic> data) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('cuotas')
        .doc(mes)
        .update(data);
  }

  static Stream<List<ModeloSocio>> streamSociosConEstadoCuota() {
    return _db
        .collection('usuarios')
        .where('rol', isEqualTo: 'socio')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ModeloSocio.fromMap(d.data()..['uid'] = d.id)).toList());
  }

  static Future<void> actualizarEstadoCuota(String uid, String estado, String? ultimaCuota) async {
    final data = {'estado_cuota': estado};
    if (ultimaCuota != null) {
      data['ultima_cuota_pagada'] = ultimaCuota;
    }
    await _db.collection('usuarios').doc(uid).update(data);
  }

}
