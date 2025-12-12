import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_socio.dart';

class AdminCuotasPantalla extends StatefulWidget {
  const AdminCuotasPantalla({super.key});

  @override
  State<AdminCuotasPantalla> createState() => _AdminCuotasPantallaState();
}

class _AdminCuotasPantallaState extends State<AdminCuotasPantalla>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Cuotas de Socios',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.white70),
          tabs: const [
            Tab(
              text: 'Activos',              
              icon: Icon(Icons.check_circle, color: Colors.white),
            ),
            Tab(
              text: 'Deudores',
              icon: Icon(Icons.warning, color: Colors.white),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabSocios('activo'),
          _buildTabSocios('deudor'),
        ],
      ),
    );
  }

  Widget _buildTabSocios(String estado) {
    return StreamBuilder<List<ModeloSocio>>(
      stream: DBServicio.streamSociosConEstadoCuota(),
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

        final todosSocios = snapshot.data ?? <ModeloSocio>[];
        
        // Filtrar socios según el estado
        List<ModeloSocio> sociosFiltrados;
        if (estado == 'activo') {
          sociosFiltrados = todosSocios
              .where((s) => s.estadoCuota == 'activo')
              .toList();
        } else {
          sociosFiltrados = todosSocios
              .where((s) => s.estadoCuota != 'activo')
              .toList();
        }

        if (sociosFiltrados.isEmpty) {
          final textoVacio = estado == 'activo'
              ? 'No hay socios activos'
              : 'No hay socios deudores';
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  estado == 'activo' ? Icons.check_circle_outline : Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  textoVacio,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sociosFiltrados.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final socio = sociosFiltrados[index];
            return _buildSocioCard(context, socio);
          },
        );
      },
    );
  }

  Widget _buildSocioCard(BuildContext context, ModeloSocio socio) {
    final isActivo = socio.estadoCuota == 'activo';
    final estadoColor = isActivo ? Colors.green : Colors.orange;
    final estadoTexto = isActivo ? 'Activo' : 'Deudor';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${socio.nombre} ${socio.apellido}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0404B9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DNI: ${socio.dni}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (socio.ultimaCuotaPagada != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Última cuota pagada: ${socio.ultimaCuotaPagada}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isActivo) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _cambiarEstado(context, socio, 'activo'),
                      icon: const Icon(Icons.check),
                      label: const Text('Marcar Activo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _cambiarEstado(context, socio, 'deudor'),
                      icon: const Icon(Icons.clear),
                      label: const Text('Marcar Deudor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarEstado(
    BuildContext context,
    ModeloSocio socio,
    String nuevoEstado,
  ) async {
    if (socio.uid == null) return;

    try {
      await DBServicio.actualizarEstadoCuota(
        socio.uid!,
        nuevoEstado,
        socio.ultimaCuotaPagada,
      );

      if (context.mounted) {
        final mensaje = nuevoEstado == 'activo'
            ? 'Socio marcado como activo'
            : 'Socio marcado como deudor';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
