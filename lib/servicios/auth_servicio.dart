import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 

  User? get usuario => _auth.currentUser;

  Stream<User?> get usuarioStream => _auth.authStateChanges();

  Future<String?> iniciarSesion(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = cred.user?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('usuarios').doc(uid).get();
    final data = doc.data();
    final rol = data != null && data['rol'] != null ? data['rol'] as String : 'socio';
    notifyListeners();
    return rol;
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    notifyListeners();
  }

  
  Future<void> crearSocio({
    required String nombre,
    required String apellido,
    required int dni,
    required String email,
    required String password,
    String rol = 'socio',
  }) async {
    // aca tuve que crear una instancia secundaria de FirebaseApp para crear el socio asi la sesión del admin no se cierra
    final String appName = 'secondary_${DateTime.now().millisecondsSinceEpoch}';
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: appName,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      // aca se crea el usuario en Auth usando la instancia secundaria
      final authResult = await secondaryAuth.createUserWithEmailAndPassword(email: email, password: password);
      final nuevo = authResult.user;
      if (nuevo == null) throw Exception('No se creó el usuario');

      // aca se escribe el documento de usuario usando la instancia secundaria de Firestore
      final FirebaseFirestore secondaryDb = FirebaseFirestore.instanceFor(app: secondaryApp);
      await secondaryDb.collection('usuarios').doc(nuevo.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'dni': dni,
        'rol': rol,
        'email': email,
        'uid': nuevo.uid,
      });
      // con esto logro cerrar sesion en la instancia secu para clean estado
      await secondaryAuth.signOut();
    } finally {
      // aca borro la secu
      await secondaryApp.delete();
    }

    
    notifyListeners();
  }
}
