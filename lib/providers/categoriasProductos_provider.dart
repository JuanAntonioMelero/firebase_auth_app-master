// lib/providers/categorias_provider.dart
import 'package:firebase_auth_app/models/categoriaProducto_model.dart';
import 'package:firebase_auth_app/services/cateogiras_productos_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- CAMBIO: El StreamProvider ahora devuelve List<CategoriaProducto> ---
final categoriasStreamProvider = StreamProvider<List<CategoriaProducto>>((ref) {
  final categoriasService = ref.watch(categoriasServiceProvider);
  return categoriasService.getCategorias();
});