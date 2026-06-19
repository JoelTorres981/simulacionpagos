class Producto {
  final String nombre;
  final double precio;
  final String iconName; // Para dar una estética premium con iconos representativos

  const Producto({
    required this.nombre,
    required this.precio,
    required this.iconName,
  });
}

// Productos base del taller
const List<Producto> productos = [
  Producto(
    nombre: 'Audífonos Bluetooth',
    precio: 25.0,
    iconName: 'headphones',
  ),
  Producto(
    nombre: 'Teclado Mecánico',
    precio: 45.0,
    iconName: 'keyboard',
  ),
  Producto(
    nombre: 'Mouse Gamer',
    precio: 30.0,
    iconName: 'mouse',
  ),
];

class PagoSimulado {
  final String id;
  final String producto;
  final double total;
  final String titular;
  final String ultimos4;
  final String estado;
  final DateTime fecha;

  PagoSimulado({
    required this.id,
    required this.producto,
    required this.total,
    required this.titular,
    required this.ultimos4,
    required this.estado,
    required this.fecha,
  });

  // Convertir a Map para guardar en Firestore o localmente
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto': producto,
      'total': total,
      'titular': titular,
      'ultimos4': ultimos4,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
    };
  }

  // Crear desde un Map (útil para Firestore y SharedPreferences)
  factory PagoSimulado.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['fecha'] is String) {
      parsedDate = DateTime.tryParse(map['fecha']) ?? DateTime.now();
    } else if (map['fecha'] != null) {
      // Por si viene de Firestore Timestamp
      parsedDate = (map['fecha'] as dynamic).toDate() as DateTime;
    } else {
      parsedDate = DateTime.now();
    }

    return PagoSimulado(
      id: docId,
      producto: map['producto'] ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      titular: map['titular'] ?? '',
      ultimos4: map['ultimos4'] ?? '',
      estado: map['estado'] ?? 'RECHAZADO',
      fecha: parsedDate,
    );
  }
}
