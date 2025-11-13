import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ActualizadorFoto extends StatefulWidget {
  final String? fotoBase64;
  final Function(Uint8List) onFotoSeleccionada;
  
  const ActualizadorFoto({
    required this.onFotoSeleccionada,
    this.fotoBase64,
  });

  @override
  State<ActualizadorFoto> createState() => _ActualizadorFotoState();
}

class _ActualizadorFotoState extends State<ActualizadorFoto> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytesSeleccionados;

  Future<void> _tomarFoto() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95, // Máxima calidad (0-100)
    );
    if (foto != null) {
      final Uint8List bytes = await foto.readAsBytes();
      setState(() {
        _bytesSeleccionados = bytes;
      });
      widget.onFotoSeleccionada(bytes);
    }
  }

  Future<void> _seleccionarGaleria() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95, // Máxima calidad (0-100)
    );
    if (foto != null) {
      final Uint8List bytes = await foto.readAsBytes();
      setState(() {
        _bytesSeleccionados = bytes;
      });
      widget.onFotoSeleccionada(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mostrar foto actual o placeholder
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7FF),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: const Color(0xFF001D5A), width: 2),
          ),
          child: _bytesSeleccionados != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.memory(_bytesSeleccionados!, fit: BoxFit.cover),
                )
              : (widget.fotoBase64 != null && widget.fotoBase64!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.memory(
                        base64Decode(widget.fotoBase64!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, color: Color(0xFFFF6B6B));
                        },
                      ),
                    )
                  : const Icon(Icons.person, size: 60, color: Color(0xFF001D5A))),
        ),
        const SizedBox(height: 16),
        // Botones para seleccionar foto
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // En web, no mostrar botón de cámara (no soportado)
            if (!kIsWeb)
              ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
            if (!kIsWeb) const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _seleccionarGaleria,
              icon: const Icon(Icons.image),
              label: const Text('Galería'),
            ),
          ],
        ),
      ],
    );
  }
}