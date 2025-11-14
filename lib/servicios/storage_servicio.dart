import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageServicio {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> subirFotoPerfil(String uid, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('perfiles/$uid/foto.jpg');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': 'flutter_app'},
        cacheControl: 'max-age=3600', 
      );
      
      await ref.putData(imageBytes, metadata);
      
      final downloadURL = await ref.getDownloadURL();
      
      return downloadURL;
    } on FirebaseException catch (e) {
      throw Exception('Error al subir foto: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido: $e');
    }
  }
}