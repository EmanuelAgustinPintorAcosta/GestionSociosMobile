import 'package:flutter/material.dart';

class InicioPantalla extends StatelessWidget {
  const InicioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Club Unión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // Mostrar logo del club desde assets/logo.png, fallback a FlutterLogo si ocurre un error
                  SizedBox(
                    height: 160,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const FlutterLogo(size: 160),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Bienvenido al Club Atlético Unión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Socios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Este es un proyecto de gestión de socios. Accede con tu cuenta para ver eventos o administrar el club.'),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
