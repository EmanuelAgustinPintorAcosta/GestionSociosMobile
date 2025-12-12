import 'package:cloud_firestore/cloud_firestore.dart';

class ModeloCuota {
  String? id;
  String mes;
  int anio;
  int monto;
  String estado; // "pendiente", "pagado", "pagando"
  Timestamp fechaVencimiento;
  Timestamp? fechaPago;
  String? mercadoPagoPreferenceId;
  String? mercadoPagoPaymentId;
  Timestamp createdAt;

  ModeloCuota({
    this.id,
    required this.mes,
    required this.anio,
    required this.monto,
    this.estado = 'pendiente',
    required this.fechaVencimiento,
    this.fechaPago,
    this.mercadoPagoPreferenceId,
    this.mercadoPagoPaymentId,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap() => {
        'mes': mes,
        'anio': anio,
        'monto': monto,
        'estado': estado,
        'fecha_vencimiento': fechaVencimiento,
        if (fechaPago != null) 'fecha_pago': fechaPago,
        if (mercadoPagoPreferenceId != null) 'mercado_pago_preference_id': mercadoPagoPreferenceId,
        if (mercadoPagoPaymentId != null) 'mercado_pago_payment_id': mercadoPagoPaymentId,
        'created_at': createdAt,
      };

  static ModeloCuota fromMap(Map<String, dynamic> map, String docId) {
    return ModeloCuota(
      id: docId,
      mes: map['mes'] ?? '',
      anio: map['anio'] ?? 2025,
      monto: map['monto'] ?? 5000,
      estado: map['estado'] ?? 'pendiente',
      fechaVencimiento: map['fecha_vencimiento'] is Timestamp
          ? map['fecha_vencimiento']
          : Timestamp.now(),
      fechaPago: map['fecha_pago'] is Timestamp ? map['fecha_pago'] : null,
      mercadoPagoPreferenceId: map['mercado_pago_preference_id'] as String?,
      mercadoPagoPaymentId: map['mercado_pago_payment_id'] as String?,
      createdAt: map['created_at'] is Timestamp ? map['created_at'] : Timestamp.now(),
    );
  }
}
