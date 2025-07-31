// lib/services/categorias_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_app/models/categoriaProducto_model.dart';
import 'package:firebase_auth_app/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Asegúrate de importar firestoreProvider

class CategoriasService {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'categoriasProductos';

  CategoriasService(this._firestore);

  // --- CAMBIO: Ahora devuelve Stream<List<CategoriaProducto>> ---
  Stream<List<CategoriaProducto>> getCategorias() {
    return _firestore.collection(_collectionName)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoriaProducto.fromFirestore(doc)) // ¡Crea objetos CategoriaProducto!
            .toList());
  }

  // Opcional: Métodos para añadir/actualizar categorías si es necesario
  Future<void> addCategoria(Map<String, dynamic> data) async {
    await _firestore.collection(_collectionName).add(data);
  }
}

final categoriasServiceProvider = Provider<CategoriasService>((ref) {
  final firestore = ref.read(firestoreProvider);
  return CategoriasService(firestore);
});