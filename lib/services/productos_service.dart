// lib/services/productos_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_app/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_app/models/producto_model.dart'; // Importa el modelo de Producto

// Este provider se asume que ya existe en pedidos_service.dart o similar
// final firestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });

class ProductosService {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'productos'; // Nombre de tu colección en Firestore

  ProductosService(this._firestore);

  // Obtener un stream de todos los productos
  Stream<List<Producto>> getProductos() {
    return _firestore.collection(_collectionName)
        .orderBy('categoria') // Ordena por categoría para la visualización
        .orderBy('nombre')    // Luego por nombre
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Producto.fromFirestore(doc))
            .toList());
  }

  // Puedes añadir métodos para añadir, actualizar o borrar productos si lo necesitas
  Future<void> addProducto(Map<String, dynamic> data) async {
    await _firestore.collection(_collectionName).add(data);
  }

  Future<void> updateProducto(String productoId, Map<String, dynamic> data) async {
    await _firestore.collection(_collectionName).doc(productoId).update(data);
  }

  Future<void> deleteProducto(String productoId) async {
    await _firestore.collection(_collectionName).doc(productoId).delete();
  }
}

// Provider que expone el ProductosService
final productosServiceProvider = Provider<ProductosService>((ref) {
  // Asegúrate de que firestoreProvider está definido y es accesible 
  final firestore = ref.read(firestoreProvider);
  return ProductosService(firestore);
});