// lib/models/pedido_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String id;
  final String mesa;
  final int comensales;
  final String estado;
  final bool pagado;
  final DateTime fecha;
  final List<Map<String, dynamic>> items; // O puedes crear un modelo para Item si quieres
  final double total;

  Pedido({
    required this.id,
    required this.mesa,
    required this.comensales,
    required this.estado,
    required this.pagado,
    required this.fecha,
    required this.items,
    required this.total,
  });

  // Factory constructor para crear un objeto Pedido desde un DocumentSnapshot de Firestore
  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pedido(
      id: doc.id, // El ID del documento de Firestore
      mesa: data['mesa'] as String,
      comensales: data['comensales'] as int,
      estado: data['estado'] as String,
      pagado: data['pagado'] as bool? ?? false, // Manejar nulos con valor por defecto
      fecha: (data['fecha'] as Timestamp).toDate(), // Convertir Timestamp a DateTime
      items: List<Map<String, dynamic>>.from(data['items'] ?? []), // Asegurar que es una lista
      total: (data['total'] as num?)?.toDouble() ?? 0.0, // Manejar nulos y convertir a double
    );
  }

  // Opcional: Método para convertir el objeto Pedido de nuevo a un Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'mesa': mesa,
      'comensales': comensales,
      'estado': estado,
      'pagado': pagado,
      'fecha': Timestamp.fromDate(fecha), // Convertir DateTime a Timestamp para Firestore
      'items': items,
      'total': total,
    };
  }
}