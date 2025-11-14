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
    dni = TextEditingController(
      text: widget.socio?.dni != null ? widget.socio!.dni.toString() : '',
    );
    email = TextEditingController(text: widget.socio?.email ?? '');
    password = TextEditingController();
    rol = widget.socio?.rol ?? 'socio';
  }

  @override
  void dispose() {
    nombre.dispose();
    apellido.dispose();
    dni.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0404B9)),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF010188), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0404B9), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.socio == null ? 'Crear Socio' : 'Editar Socio',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0404B9),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: nombre,
                    decoration: _buildInputDecoration('Nombre', Icons.person),
                    validator: (v) => (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: apellido,
                    decoration: _buildInputDecoration('Apellido', Icons.person_outline),
                    validator: (v) => (v == null || v.isEmpty) ? 'El apellido es requerido' : null,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: dni,
                    decoration: _buildInputDecoration('DNI', Icons.badge),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'El DNI es requerido' : null,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: email,
                    decoration: _buildInputDecoration('Email', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v != null && v.contains('@')) ? null : 'Email inválido',
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: password,
                    decoration: _buildInputDecoration(
                      widget.socio == null
                          ? 'Contraseña'
                          : 'Contraseña (dejar en blanco para no cambiar)',
                      Icons.lock,
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: rol,
                    items: const [
                      DropdownMenuItem(
                        value: 'socio',
                        child: Text('Socio'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador'),
                      ),
                    ],
                    onChanged: (v) => setState(() => rol = v ?? 'socio'),
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      prefixIcon:
                          const Icon(Icons.security, color: Color(0xFF0404B9)),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF010188), width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF0404B9), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0404B9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF010188), Color(0xFF0404B9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF0404B9).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (!_formKey.currentState!.validate()) return;
                              final parsedDni =
                                  int.tryParse(dni.text.trim()) ?? 0;
                              final modelo = ModeloSocio(
                                uid: widget.socio?.uid,
                                nombre: nombre.text.trim(),
                                apellido: apellido.text.trim(),
                                dni: parsedDni,
                                rol: rol,
                                email: email.text.trim(),
                              );
                              Navigator.of(context).pop({
                                'socio': modelo,
                                'password': password.text
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  widget.socio == null ? 'Crear' : 'Guardar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
