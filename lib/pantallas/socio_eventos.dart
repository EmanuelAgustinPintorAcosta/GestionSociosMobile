import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_evento.dart';
import '../servicios/auth_servicio.dart';

class SocioEventosPantalla extends StatelessWidget {
  const SocioEventosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/perfil'), icon: const Icon(Icons.person)),
          IconButton(
            onPressed: () async {
              await auth.cerrarSesion();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<List<ModeloEvento>>(
        stream: DBServicio.streamEventos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final eventos = snapshot.data!;
          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, i) {
              final e = eventos[i];
              return Card(
                color: const Color(0xFFE6F7FF),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(e.titulo),
                  subtitle: Text('${e.descripcion}\n${e.fecha.toLocal()}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
