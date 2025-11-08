import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

Future<void> inicializarFirebase() async {
  // Inicializa Firebase usando las opciones generadas por FlutterFire CLI
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print('Firebase inicializado');
  }
}
