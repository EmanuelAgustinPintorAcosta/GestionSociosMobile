import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_asunto.dart';

class AdminInicioPantalla extends StatelessWidget {
  const AdminInicioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrador'),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text('Gestionar Socios'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.pushNamed(context, '/admin_socios'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.event),
              label: const Text('Gestionar Eventos'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.pushNamed(context, '/admin_eventos'),
            ),
            const SizedBox(height: 16),
            // Botón Asuntos con badge de asuntos no leídos
            StreamBuilder<List<ModeloAsunto>>(
              stream: DBServicio.streamAsuntos(),
              builder: (context, snap) {
                final asuntos = snap.data ?? <ModeloAsunto>[];
                final unread = asuntos.where((a) => a.leido == false).length;
                return SizedBox(
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.mark_email_read),
                        label: const Text('Asuntos'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/admin_asuntos'),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            child: Center(
                              child: Text(
                                '$unread',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
