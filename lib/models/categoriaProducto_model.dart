// lib/models/categoria_producto_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaProducto {
  final String id;
  final String nombre;

  // Puedes añadir más propiedades aquí en el futuro, por ejemplo:
  // final String? iconoUrl;
  // final int? orden;

  CategoriaProducto({
    required this.id,
    required this.nombre,
    // this.iconoUrl,
    // this.orden,
  });

  // Factory constructor para crear un objeto CategoriaProducto desde un DocumentSnapshot de Firestore
  factory CategoriaProducto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoriaProducto(
      id: doc.id,
      nombre: data['nombre'] as String? ?? 'Desconocido',
      // iconoUrl: data['iconoUrl'] as String?,
      // orden: (data['orden'] as num?)?.toInt(),
    );
  }

  // Opcional: Para convertir a Map si necesitas enviarlo de vuelta a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      // 'iconoUrl': iconoUrl,
      // 'orden': orden,
    };
  }

  // Opcional: Sobrescribir == y hashCode para comparar objetos CategoriaProducto
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaProducto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre; // Compara por id y nombre

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode;
}