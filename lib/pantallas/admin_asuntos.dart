import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../servicios/auth_servicio.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_asunto.dart';

class AdminAsuntosPantalla extends StatelessWidget {
  const AdminAsuntosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asuntos'),
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
      body: StreamBuilder<List<ModeloAsunto>>(
        stream: DBServicio.streamAsuntos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final asuntos = snapshot.data!;
          if (asuntos.isEmpty) return const Center(child: Text('No hay asuntos'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: asuntos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = asuntos[i];
              final fechaStr = DateTime.fromMillisecondsSinceEpoch(a.fecha.seconds * 1000).toLocal().toString().split('.').first;
              final isLeido = a.leido;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(a.asunto, style: const TextStyle(fontWeight: FontWeight.bold)),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enviado por: ${a.nombre} ${a.apellido}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text('Email: ${a.email}', style: TextStyle(color: Colors.grey[700])),
                            const Divider(),
                            Text(a.descripcion),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            // marcar como leido (toggle)
                            await DBServicio.marcarLeido(a.id ?? '', true);
                          },
                          child: const Text('Marcar como leído'),
                        ),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          child: (a.fotoBase64 != null && a.fotoBase64!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.memory(
                                    base64Decode(a.fotoBase64!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text(
                                        '${a.nombre.isNotEmpty ? a.nombre[0] : ''}${a.apellido.isNotEmpty ? a.apellido[0] : ''}'.toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  '${a.nombre.isNotEmpty ? a.nombre[0] : ''}${a.apellido.isNotEmpty ? a.apellido[0] : ''}'.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.asunto, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isLeido ? Colors.grey[600] : Colors.black)),
                              const SizedBox(height: 4),
                              Text('${a.nombre} ${a.apellido} — ${a.email}', style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(fechaStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    // toggle leído
                                    await DBServicio.marcarLeido(a.id ?? '', !(a.leido));
                                  },
                                  icon: Icon(
                                    isLeido ? Icons.mark_email_read : Icons.mark_email_unread,
                                    color: isLeido ? Theme.of(context).colorScheme.primary : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () async {
                                    // eliminar asunto directamente desde la lista
                                    await DBServicio.eliminarAsunto(a.id ?? '');
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
