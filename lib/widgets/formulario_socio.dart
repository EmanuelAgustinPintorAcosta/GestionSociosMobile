import 'package:flutter/material.dart';
import '../modelos/modelo_socio.dart';

class FormularioSocio extends StatefulWidget {
  final ModeloSocio? socio;
  const FormularioSocio({super.key, this.socio});

  @override
  State<FormularioSocio> createState() => _FormularioSocioState();
}

class _FormularioSocioState extends State<FormularioSocio> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombre;
  late TextEditingController apellido;
  late TextEditingController dni;
  late TextEditingController email;
  late TextEditingController password;
  String rol = 'socio';

  @override
  void initState() {
    super.initState();
    nombre = TextEditingController(text: widget.socio?.nombre ?? '');
    apellido = TextEditingController(text: widget.socio?.apellido ?? '');
  dni = TextEditingController(text: widget.socio?.dni != null ? widget.socio!.dni.toString() : '');
    email = TextEditingController(text: widget.socio?.email ?? '');
    password = TextEditingController();
    rol = widget.socio?.rol ?? 'socio';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
              TextFormField(controller: apellido, decoration: const InputDecoration(labelText: 'Apellido'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
              TextFormField(controller: dni, decoration: const InputDecoration(labelText: 'DNI'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
              TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v!=null && v.contains('@'))?null:'Email inválido'),
              const SizedBox(height: 8),
              TextFormField(controller: password, decoration: const InputDecoration(labelText: 'Contraseña (nuevo usuario)'), obscureText: true),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: rol,
                items: const [
                  DropdownMenuItem(value: 'socio', child: Text('Socio')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => rol = v ?? 'socio'),
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  final parsedDni = int.tryParse(dni.text.trim()) ?? 0;
                  final modelo = ModeloSocio(
                    uid: widget.socio?.uid,
                    nombre: nombre.text.trim(),
                    apellido: apellido.text.trim(),
                    dni: parsedDni,
                    rol: rol,
                    email: email.text.trim(),
                  );
                  Navigator.of(context).pop({'socio': modelo, 'password': password.text});
                },
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
