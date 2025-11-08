import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_servicio.dart';

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _cargando = false;
  bool _showPassword = false;
  bool _logoVisible = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Card contenedor para un look más moderno
              Center(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        AnimatedOpacity(
                          opacity: _logoVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 600),
                          child: SizedBox(
                            height: 120,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const FlutterLogo(size: 120),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (v) => (v != null && v.contains('@')) ? null : 'Email inválido',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          obscureText: !_showPassword,
                          validator: (v) => (v != null && v.length >= 6) ? null : 'Contraseña mínima 6 caracteres',
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        _cargando
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    setState(() => _cargando = true);
                                    try {
                                      final rol = await auth.iniciarSesion(_email.text.trim(), _password.text.trim());
                                      if (rol == 'admin') {
                                        Navigator.pushReplacementNamed(context, '/admin_inicio');
                                      } else {
                                        Navigator.pushReplacementNamed(context, '/socio_inicio');
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    } finally {
                                      setState(() => _cargando = false);
                                    }
                                  },
                                  child: const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // animar logo al cargar
    Future.delayed(const Duration(milliseconds: 150), () { if (mounted) setState(() => _logoVisible = true); });
  }
}
