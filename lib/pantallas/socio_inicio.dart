import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_servicio.dart';

class SocioInicioPantalla extends StatelessWidget {
  const SocioInicioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socio'),
        automaticallyImplyLeading: false,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.event),
                label: const Text('Ver eventos'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => Navigator.pushNamed(context, '/socio_eventos'),
              ),
              const SizedBox(height: 12),
              // Botón para contactar al administrador al mismo nivel estético que Ver eventos
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Contactarse con administrador'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => Navigator.pushNamed(context, '/contactar_admin'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Mi perfil'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => Navigator.pushNamed(context, '/perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
