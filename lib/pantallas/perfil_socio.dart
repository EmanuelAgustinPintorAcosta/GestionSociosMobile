import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_servicio.dart';

class PerfilSocioPantalla extends StatelessWidget {
  const PerfilSocioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
  final auth = Provider.of<AuthService>(context);
  final uid = auth.usuario?.uid;
  if (uid == null) return Scaffold(body: Center(child: Text('No hay usuario')));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) return const Center(child: Text('Sin datos'));
          // Enhanced profile card
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFF001D5A),
                            child: Text(
                              '${(data['nombre'] ?? '').toString().isNotEmpty ? (data['nombre'][0] ?? '') : ''}${(data['apellido'] ?? '').toString().isNotEmpty ? (data['apellido'][0] ?? '') : ''}'.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  data['email'] ?? '',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      // (Removed duplicate 'Contactarse' button — available in SocioInicio)
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Color(0xFF001D5A)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DNI', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('${data['dni'] ?? ''}'),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.work, color: Color(0xFF001D5A)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rol', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('${data['rol'] ?? ''}'),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
