import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../servicios/auth_servicio.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_asunto.dart';

class AdminAsuntosPantalla extends StatefulWidget {
  const AdminAsuntosPantalla({super.key});

  @override
  State<AdminAsuntosPantalla> createState() => _AdminAsuntosPantallaState();
}

class _AdminAsuntosPantallaState extends State<AdminAsuntosPantalla> {
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
          'Asuntos de Socios',
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
      body: StreamBuilder<List<ModeloAsunto>>(
        stream: DBServicio.streamAsuntos(),
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
          final asuntos = snapshot.data!;
          if (asuntos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay asuntos',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: asuntos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final a = asuntos[i];
              final fechaStr = DateTime.fromMillisecondsSinceEpoch(a.fecha.seconds * 1000)
                  .toLocal()
                  .toString()
                  .split('.')
                  .first;
              final isLeido = a.leido;
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
                  border: Border.all(
                    color: isLeido ? Colors.grey[300]! : const Color(0xFF0404B9),
                    width: isLeido ? 0.5 : 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.asunto,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0404B9),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF010188).withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${a.nombre} ${a.apellido}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        a.email,
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  a.descripcion,
                                  style: const TextStyle(fontSize: 14, height: 1.6),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'Cerrar',
                                        style: TextStyle(
                                          color: Color(0xFF0404B9),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (!a.respondido)
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF010188), Color(0xFF0404B9)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _mostrarModalResponder(context, a);
                                            },
                                            borderRadius: BorderRadius.circular(8),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                              child: Text(
                                                'Responder',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.check, color: Colors.green),
                                            SizedBox(width: 4),
                                            Text(
                                              'Respondido',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF010188), Color(0xFF0404B9)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            await DBServicio.marcarLeido(a.id ?? '', true);
                                            Navigator.of(context).pop();
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              'Marcar como leído',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
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
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isLeido
                                ? Colors.grey[300]
                                : const Color(0xFF0404B9),
                            child: (a.fotoBase64 != null && a.fotoBase64!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Image.memory(
                                      base64Decode(a.fotoBase64!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Text(
                                          '${a.nombre.isNotEmpty ? a.nombre[0] : ''}${a.apellido.isNotEmpty ? a.apellido[0] : ''}'
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Text(
                                    '${a.nombre.isNotEmpty ? a.nombre[0] : ''}${a.apellido.isNotEmpty ? a.apellido[0] : ''}'
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Nombre del remitente (primero) - BIEN VISIBLE
                                DefaultTextStyle(
                                  style: const TextStyle(color: Color(0xFF0404B9)),
                                  child: Text(
                                    '${a.nombre} ${a.apellido}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0404B9),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Asunto (segundo)
                                DefaultTextStyle(
                                  style: TextStyle(color: isLeido ? Colors.grey[600]! : const Color(0xFF0404B9)),
                                  child: Text(
                                    a.asunto,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isLeido ? Colors.grey[600] : const Color(0xFF0404B9),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Fecha (tercero)
                                DefaultTextStyle(
                                  style: TextStyle(color: Colors.grey[500]!),
                                  child: Text(
                                    fechaStr,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await DBServicio.marcarLeido(a.id ?? '', !(a.leido));
                                },
                                icon: Icon(
                                  isLeido ? Icons.mark_email_read : Icons.mark_email_unread,
                                  color: isLeido
                                      ? Colors.grey[400]
                                      : const Color(0xFF0404B9),
                                  size: 24,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await DBServicio.eliminarAsunto(a.id ?? '');
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
    );
  }

  void _mostrarModalResponder(BuildContext context, ModeloAsunto asunto) {
    final respuestaCtrl = TextEditingController();
    bool enviando = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Responder Asunto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0404B9),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Asunto original
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0404B9).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF0404B9).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asunto Original',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        asunto.asunto,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0404B9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        asunto.descripcion,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campo respuesta
                Container(
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
                  child: TextFormField(
                    controller: respuestaCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Tu Respuesta',
                      labelStyle: const TextStyle(color: Color(0xFF0404B9)),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.reply,
                          color: Color(0xFF0404B9),
                        ),
                      ),
                      hintText: 'Escribe la respuesta al socio...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF0404B9),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF0404B9),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0404B9).withValues(alpha: 0.02),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: enviando ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color(0xFF0404B9),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                              color: const Color(0xFF0404B9).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: enviando
                              ? null
                              : () async {
                                  if (respuestaCtrl.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Por favor escribe una respuesta'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => enviando = true);

                                  try {
                                    await DBServicio.responderAsunto(
                                      asunto.id ?? '',
                                      respuestaCtrl.text.trim(),
                                    );

                                    // Marcar como leído cuando el admin responde
                                    await DBServicio.marcarLeido(asunto.id ?? '', true);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Respuesta enviada exitosamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    setState(() => enviando = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: enviando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Enviar Respuesta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
