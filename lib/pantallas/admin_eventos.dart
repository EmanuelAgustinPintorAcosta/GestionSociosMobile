import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_evento.dart';
import '../widgets/formulario_evento.dart';
import '../servicios/auth_servicio.dart';

class AdminEventosPantalla extends StatelessWidget {
  const AdminEventosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Eventos'),
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
                color: const Color(0xFFE6F0FF),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(e.titulo),
                  subtitle: Text('${e.descripcion}\n${e.fecha.toLocal()}'),
                  isThreeLine: true,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(onPressed: () async {
                      final actualizado = await showDialog<ModeloEvento>(context: context, builder: (_) => Dialog(child: FormularioEvento(evento: e)));
                      if (actualizado != null) await DBServicio.actualizarEvento(actualizado);
                    }, icon: const Icon(Icons.edit)),
                    IconButton(onPressed: () async { await DBServicio.eliminarEvento(e.id ?? ''); }, icon: const Icon(Icons.delete, color: Colors.red))
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final nuevo = await showDialog<ModeloEvento>(context: context, builder: (_) => const Dialog(child: FormularioEvento()));
        if (nuevo != null) await DBServicio.crearEvento(nuevo);
      }, child: const Icon(Icons.add)),
    );
  }
}
