// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0q4v6ErGbF8FZahiwb69TTkVUNSvgZZE',
    appId: '1:492393770109:web:88d73f4dfe96767a631514',
    messagingSenderId: '492393770109',
    projectId: 'gestionsociospintor',
    authDomain: 'gestionsociospintor.firebaseapp.com',
    storageBucket: 'gestionsociospintor.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_VQUCg_MtFKtnmC4WW0rbOEIecUY3qLY',
    appId: '1:492393770109:android:fea7a65ea17cbae7631514',
    messagingSenderId: '492393770109',
    projectId: 'gestionsociospintor',
    storageBucket: 'gestionsociospintor.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDco9SUwZx7U2SiILJZCoM0JOANHxZ3Lrg',
    appId: '1:492393770109:ios:2271d68e89c88def631514',
    messagingSenderId: '492393770109',
    projectId: 'gestionsociospintor',
    storageBucket: 'gestionsociospintor.firebasestorage.app',
    iosBundleId: 'com.example.gestionsociospintor',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDco9SUwZx7U2SiILJZCoM0JOANHxZ3Lrg',
    appId: '1:492393770109:ios:2271d68e89c88def631514',
    messagingSenderId: '492393770109',
    projectId: 'gestionsociospintor',
    storageBucket: 'gestionsociospintor.firebasestorage.app',
    iosBundleId: 'com.example.gestionsociospintor',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC0q4v6ErGbF8FZahiwb69TTkVUNSvgZZE',
    appId: '1:492393770109:web:de30bd409fdb699e631514',
    messagingSenderId: '492393770109',
    projectId: 'gestionsociospintor',
    authDomain: 'gestionsociospintor.firebaseapp.com',
    storageBucket: 'gestionsociospintor.firebasestorage.app',
  );
}
