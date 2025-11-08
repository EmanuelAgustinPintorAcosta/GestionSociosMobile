import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_asunto.dart';

class ContactarAdminPantalla extends StatefulWidget {
  const ContactarAdminPantalla({super.key});

  @override
  State<ContactarAdminPantalla> createState() => _ContactarAdminPantallaState();
}

class _ContactarAdminPantallaState extends State<ContactarAdminPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _asuntoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _asuntoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final usuario = auth.usuario;
    final nombre = usuario?.displayName ?? '';
    final email = usuario?.email ?? '';
    final uid = usuario?.uid;

    final asunto = ModeloAsunto(
      uidSocio: uid,
      nombre: nombre.split(' ').isNotEmpty ? nombre.split(' ').first : '',
      apellido: nombre.split(' ').length > 1 ? nombre.split(' ').sublist(1).join(' ') : '',
      email: email,
      asunto: _asuntoCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
    );

    try {
      await DBServicio.crearAsunto(asunto);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviado al administrador')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactar al administrador'),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.cerrarSesion();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _asuntoCtrl,
                decoration: const InputDecoration(labelText: 'Asunto'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un asunto' : null,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _descripcionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese una descripción' : null,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _enviando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
                  label: const Text('Enviar'),
                  onPressed: _enviando ? null : () => _enviar(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
