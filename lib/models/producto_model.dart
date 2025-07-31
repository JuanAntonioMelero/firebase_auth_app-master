// lib/models/producto_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  final String imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.imagen,
  });

  // Factory constructor para crear un objeto Producto desde un DocumentSnapshot de Firestore
  factory Producto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Producto(
      id: doc.id,
      nombre: data['nombre'] as String? ?? 'Desconocido',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      categoria: data['categoria'] as String? ?? 'Sin Categoría',
      imagen: data['imagen'] as String? ?? 'https://via.placeholder.com/150', // Imagen por defecto
    );
  }

  // Opcional: Para convertir a Map si necesitas enviarlo de vuelta a Firestore (no para este caso)
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'imagen': imagen,
    };
  }
}