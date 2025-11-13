import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/modelo_socio.dart';
import '../modelos/modelo_evento.dart';
import '../modelos/modelo_asunto.dart';

class DBServicio {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Socios
  static Stream<List<ModeloSocio>> streamSocios() {
    return _db.collection('usuarios').snapshots().map((snap) =>
        snap.docs.map((d) => ModeloSocio.fromMap(d.data()..['uid'] = d.id)).toList());
  }

  static Future<Map<String, dynamic>?> obtenerSocio(String uid) async {
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

  // Eventos
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


  // Asuntos (mensajes de socios al administrador)
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
}
