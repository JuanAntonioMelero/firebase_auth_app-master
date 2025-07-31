// lib/providers/pedidos_provider.dart
import 'package:firebase_auth_app/models/pedido_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_app/services/pedidos_service.dart'; // ¡Importa tu servicio!


// StreamProvider para los pedidos activos (ahora List<Pedido>)
final pedidosStreamProvider = StreamProvider<List<Pedido>>((ref) {
  final pedidosService = ref.watch(pedidosServiceProvider);
  return pedidosService.getPedidosActivos();
});


// StreamProvider para un pedido específico por su ID (ahora Pedido)
final pedidoByIdStreamProvider = StreamProvider.family<Pedido, String>((ref, pedidoId) {
  final pedidosService = ref.watch(pedidosServiceProvider);
  return pedidosService.getPedidoById(pedidoId);
});