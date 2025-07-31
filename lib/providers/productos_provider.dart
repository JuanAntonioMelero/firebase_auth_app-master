// lib/providers/productos_provider.dart
import 'package:firebase_auth_app/services/productos_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_app/models/producto_model.dart';      // Importa el modelo de Producto

// StreamProvider para obtener todos los productos del menú
final productosStreamProvider = StreamProvider<List<Producto>>((ref) {
  final productosService = ref.watch(productosServiceProvider);
  return productosService.getProductos();
});