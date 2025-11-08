import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/db_servicio.dart';
import '../servicios/auth_servicio.dart';
import '../modelos/modelo_socio.dart';
import '../widgets/formulario_socio.dart';

class AdminSociosPantalla extends StatelessWidget {
  const AdminSociosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
  final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Socios'),
        actions: [
          IconButton(
              onPressed: () async {
                await auth.cerrarSesion();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<List<ModeloSocio>>(
        stream: DBServicio.streamSocios(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final socios = snapshot.data!;
          return ListView.builder(
            itemCount: socios.length,
            itemBuilder: (context, i) {
              final s = socios[i];
              return Card(
                color: const Color(0xFFEAF2FF), // light blue background for contrast
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF001D5A),
                    child: Text(
                      '${s.nombre.substring(0, 1).toUpperCase()}${s.apellido.substring(0, 1).toUpperCase()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${s.nombre} ${s.apellido}'),
                  subtitle: Text('DNI: ${s.dni} • ${s.email} • rol: ${s.rol}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        onPressed: () async {
                          final resultado = await showDialog<dynamic>(
                              context: context,
                              builder: (_) => Dialog(child: FormularioSocio(socio: s)));
                          if (resultado != null && resultado is Map) {
                            final actualizado = resultado['socio'] as ModeloSocio;
                            await DBServicio.actualizarSocio(actualizado);
                          }
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () async {
                          await DBServicio.eliminarSocio(s.uid ?? '');
                        },
                        icon: const Icon(Icons.delete, color: Colors.red))
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final resultado = await showDialog<dynamic>(context: context, builder: (_) => const Dialog(child: FormularioSocio()));
          if (resultado != null && resultado is Map) {
            final modelo = resultado['socio'] as ModeloSocio;
            final pwd = (resultado['password'] as String?) ?? '';
            try {
              // Intentar crear también la cuenta en Auth (esto reautentica internamente al admin si está cacheado)
              await auth.crearSocio(nombre: modelo.nombre, apellido: modelo.apellido, dni: modelo.dni, email: modelo.email, password: pwd, rol: modelo.rol);
              // Firestore ya se creó en crearSocio; si se prefiere, actualizar o crear documento adicional
            } catch (e) {
              // En caso de fallo, intentar crear solo documento
              await DBServicio.crearSocio(modelo);
            }
          }
        },
      ),
    );
  }
}
