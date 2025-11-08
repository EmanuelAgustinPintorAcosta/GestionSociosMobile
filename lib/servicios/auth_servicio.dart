import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // No se cachean credenciales: usamos instancia secundaria para crear usuarios

  User? get usuario => _auth.currentUser;

  Stream<User?> get usuarioStream => _auth.authStateChanges();

  Future<String?> iniciarSesion(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = cred.user?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('usuarios').doc(uid).get();
    final data = doc.data();
    final rol = data != null && data['rol'] != null ? data['rol'] as String : 'socio';
    // No cacheamos credenciales; las creaciones de usuario no cambiarán la sesión
    notifyListeners();
    return rol;
  }

  Future<void> cerrarSesion() async {
    // Cerrar sesión principal
    await _auth.signOut();
    notifyListeners();
  }

  // Crea un socio en Auth y en Firestore. Nota: crear usuario desde cliente
  // firma al nuevo usuario; reautentica con credenciales admin en memoria.
  Future<void> crearSocio({
    required String nombre,
    required String apellido,
    required int dni,
    required String email,
    required String password,
    String rol = 'socio',
  }) async {
    // Creamos una instancia secundaria de FirebaseApp para realizar la
    // creación del usuario y la escritura del documento desde esa instancia.
    // De este modo la sesión del usuario principal (el admin) no se ve afectada.
    final String appName = 'secondary_${DateTime.now().millisecondsSinceEpoch}';
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: appName,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      // Crear el usuario en Auth usando la instancia secundaria
      final authResult = await secondaryAuth.createUserWithEmailAndPassword(email: email, password: password);
      final nuevo = authResult.user;
      if (nuevo == null) throw Exception('No se creó el usuario');

      // Escribir el documento de usuario usando la instancia secundaria de Firestore
      final FirebaseFirestore secondaryDb = FirebaseFirestore.instanceFor(app: secondaryApp);
      await secondaryDb.collection('usuarios').doc(nuevo.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'dni': dni,
        'rol': rol,
        'email': email,
        'uid': nuevo.uid,
      });

      // Cerrar sesión en la instancia secundaria para limpiar su estado
      await secondaryAuth.signOut();
    } finally {
      // Borrar la app secundaria (libera recursos)
      await secondaryApp.delete();
    }

    // No tocamos la sesión principal (_auth) — el admin permanece logueado.
    notifyListeners();
  }
}
