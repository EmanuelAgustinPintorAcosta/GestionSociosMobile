import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0404B9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gestionar Socios',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.cerrarSesion();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: StreamBuilder<List<ModeloSocio>>(
        stream: DBServicio.streamSocios(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFF0404B9), fontSize: 16),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0404B9)),
            );
          }
          final socios = snapshot.data!;
          if (socios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay socios registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: socios.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = socios[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final resultado = await showDialog<dynamic>(
                        context: context,
                        builder: (_) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: FormularioSocio(socio: s),
                        ),
                      );
                      if (resultado != null && resultado is Map) {
                        final actualizado = resultado['socio'] as ModeloSocio;
                        await DBServicio.actualizarSocio(actualizado);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF010188), Color(0xFF0404B9)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              child: (s.fotoBase64 != null && s.fotoBase64!.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(26),
                                      child: Image.memory(
                                        base64Decode(s.fotoBase64!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Text(
                                            '${s.nombre.substring(0, 1).toUpperCase()}${s.apellido.substring(0, 1).toUpperCase()}',
                                            style: const TextStyle(
                                              color: Color(0xFF0404B9),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Text(
                                      '${s.nombre.substring(0, 1).toUpperCase()}${s.apellido.substring(0, 1).toUpperCase()}',
                                      style: const TextStyle(
                                        color: Color(0xFF0404B9),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${s.nombre} ${s.apellido}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0404B9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'DNI: ${s.dni}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: s.rol == 'admin'
                                            ? const Color(0xFF010188).withValues(alpha: 0.1)
                                            : const Color(0xFF0404B9).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        s.rol,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: s.rol == 'admin'
                                              ? const Color(0xFF010188)
                                              : const Color(0xFF0404B9),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final resultado = await showDialog<dynamic>(
                                    context: context,
                                    builder: (_) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: FormularioSocio(socio: s),
                                    ),
                                  );
                                  if (resultado != null && resultado is Map) {
                                    final actualizado = resultado['socio'] as ModeloSocio;
                                    await DBServicio.actualizarSocio(actualizado);
                                  }
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF0404B9),
                                  size: 24,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Eliminar Socio'),
                                      content: Text(
                                        '¿Está seguro de que desea eliminar a ${s.nombre} ${s.apellido}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmar == true) {
                                    await DBServicio.eliminarSocio(s.uid ?? '');
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF010188), Color(0xFF0404B9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0404B9).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final resultado = await showDialog<dynamic>(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const FormularioSocio(),
                ),
              );
              if (resultado != null && resultado is Map) {
                final modelo = resultado['socio'] as ModeloSocio;
                final pwd = (resultado['password'] as String?) ?? '';
                try {
                  await auth.crearSocio(
                    nombre: modelo.nombre,
                    apellido: modelo.apellido,
                    dni: modelo.dni,
                    email: modelo.email,
                    password: pwd,
                    rol: modelo.rol,
                  );
                } catch (e) {
                  await DBServicio.crearSocio(modelo);
                }
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
