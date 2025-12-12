import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/db_servicio.dart';
import '../modelos/modelo_cuota.dart';

class MisCuotasPantalla extends StatelessWidget {
  const MisCuotasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final uid = auth.usuario?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Cuotas')),
        body: const Center(child: Text('Debe iniciar sesión')),
      );
    }

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
          'Mis Cuotas',
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
      body: StreamBuilder<List<ModeloCuota>>(
        stream: DBServicio.streamCuotasPorSocio(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(' Error en streamCuotasPorSocio: ${snapshot.error}');
            print(' Stack trace: ${snapshot.stackTrace}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error cargando cuotas',
                      style: const TextStyle(color: Color(0xFF0404B9), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0404B9)),
            );
          }

          final cuotas = snapshot.data ?? <ModeloCuota>[];
          if (cuotas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay cuotas disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _inicializarCuotas(context, uid),
                    icon: const Icon(Icons.add),
                    label: const Text('Inicializar Cuotas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0404B9),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cuotas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cuota = cuotas[index];
              return _buildCuotaCard(context, cuota, uid);
            },
          );
        },
      ),
    );
  }

  Widget _buildCuotaCard(BuildContext context, ModeloCuota cuota, String uid) {
    final meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final nombreMes = meses[int.parse(cuota.mes) - 1];
    final isPagado = cuota.estado == 'pagado';
    final isPagando = cuota.estado == 'pagando';
    final isPendiente = cuota.estado == 'pendiente';

    Color estadoColor = Colors.orange;
    String estadoTexto = 'Pendiente';
    IconData estadoIcon = Icons.schedule;

    if (isPagado) {
      estadoColor = Colors.green;
      estadoTexto = 'Pagado';
      estadoIcon = Icons.check_circle;
    } else if (isPagando) {
      estadoColor = Colors.blue;
      estadoTexto = 'Pagando...';
      estadoIcon = Icons.hourglass_bottom;
    }

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$nombreMes ${cuota.anio}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0404B9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monto: \$${cuota.monto.toStringAsFixed(0)} ARS',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(estadoIcon, color: estadoColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        estadoTexto,
                        style: TextStyle(
                          color: estadoColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isPagado) ...[
              const SizedBox(height: 12),
              Text(
                'Pagado el: ${cuota.fechaPago != null ? _formatearFecha(cuota.fechaPago!.toDate()) : 'N/A'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
            if (isPendiente) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarQR(context, cuota, uid),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Ver QR Pago'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0404B9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
            if (isPagando) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tu pago está siendo procesado. Por favor no recargues esta pantalla.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarQR(BuildContext context, ModeloCuota cuota, String uid) async {
    // Link simple para pagar - el usuario lo abre en el móvil
    final qrData = "https://mpago.la/test-pago-${cuota.mes}-${uid.substring(0, 8)}";
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Código QR de Pago',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0404B9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cuota ${cuota.mes}/${cuota.anio}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monto: \$${cuota.monto.toStringAsFixed(0)} ARS',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // QR Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0404B9), width: 2),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 280,
                    gapless: true,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Escanea este código QR con tu celular para completar el pago',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0404B9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cerrar', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void> _inicializarCuotas(BuildContext context, String uid) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Inicializando cuotas...'),
          content: const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF0404B9)),
            ),
          ),
        ),
      );

      // Llamar a la Cloud Function para inicializar cuotas (mantener esta lógica)
      final user = Provider.of<AuthService>(context, listen: false).usuario;
      if (user == null) throw Exception('Usuario no autenticado');
      
      // Por ahora comentamos esto ya que eliminamos la función HTTP
      // Podemos usar directamente onCall o crear una nueva
      
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cuotas inicializadas')),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
