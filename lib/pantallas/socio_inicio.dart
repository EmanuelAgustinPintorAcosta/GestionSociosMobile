import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_servicio.dart';

class SocioInicioPantalla extends StatelessWidget {
  const SocioInicioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF010188), Color(0xFF0404b9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido, Socio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Tu espacio en el club',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      await auth.cerrarSesion();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                    tooltip: 'Cerrar sesión',
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuButton(
                    context,
                    icon: Icons.event,
                    label: 'Ver Eventos',
                    onPressed: () => Navigator.pushNamed(context, '/socio_eventos'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuButton(
                    context,
                    icon: Icons.email,
                    label: 'Contactar Administrador',
                    onPressed: () => Navigator.pushNamed(context, '/contactar_admin'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuButton(
                    context,
                    icon: Icons.mail_outline,
                    label: 'Mis Asuntos',
                    onPressed: () => Navigator.pushNamed(context, '/mis_asuntos'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuButton(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Mis Cuotas',
                    onPressed: () => Navigator.pushNamed(context, '/mis_cuotas'),
                  ),
                  const SizedBox(height: 16),
  
                  _buildMenuButton(
                    context,
                    icon: Icons.person,
                    label: 'Mi Perfil',
                    onPressed: () => Navigator.pushNamed(context, '/perfil'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF010188), Color(0xFF0404b9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0404b9).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
