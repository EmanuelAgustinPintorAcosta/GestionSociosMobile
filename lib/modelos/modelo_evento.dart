class ModeloEvento {
  String? id;
  String titulo;
  String descripcion;
  DateTime fecha;

  ModeloEvento({this.id, required this.titulo, required this.descripcion, required this.fecha});

  factory ModeloEvento.fromMap(Map<String, dynamic> m) {
    final ts = m['fecha'];
    DateTime dt;
    if (ts is DateTime) {
      dt = ts;
    } else if (ts is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is Map && ts['_seconds'] != null) {
      dt = DateTime.fromMillisecondsSinceEpoch((ts['_seconds'] as int) * 1000);
    } else {
      dt = DateTime.now();
    }

    return ModeloEvento(
      id: m['id']?.toString(),
      titulo: (m['titulo'] ?? '') as String,
      descripcion: (m['descripcion'] ?? '') as String,
      fecha: dt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha,
    };
  }
}
