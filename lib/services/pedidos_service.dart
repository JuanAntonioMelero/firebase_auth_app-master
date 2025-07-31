// lib/services/pedidos_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_app/models/pedido_model.dart';
import 'package:firebase_auth_app/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Servicio para interactuar con la colección 'pedidos'
class PedidosService {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'pedidos'; // Nombre de la colección

  PedidosService(this._firestore);

  // 1. Método para OBTENER UN STREAM DE TODOS LOS PEDIDOS (ahora List<Pedido>)
  Stream<List<Pedido>> getPedidos() {
    return _firestore.collection(_collectionName)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pedido.fromFirestore(doc)) // ¡Mapea cada DocumentSnapshot a un Pedido!
            .toList());
  }

 // 2. Método para obtener un stream de PEDIDOS ACTIVOS (ahora List<Pedido>)
  Stream<List<Pedido>> getPedidosActivos() {
    return _firestore.collection(_collectionName)
        // Usar whereIn para incluir solo los estados que consideras "activos"
        .where('estado', whereIn: ['pendiente', 'en_preparacion', 'en_entrega']) // <--- ¡Modifica esto!
        
        .orderBy('estado')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pedido.fromFirestore(doc)) // ¡Mapea cada DocumentSnapshot a un Pedido!
            .toList());
  }

 // 3. Método para obtener un stream de un PEDIDO ESPECÍFICO por su ID (ahora Pedido)
  Stream<Pedido> getPedidoById(String pedidoId) {
    return _firestore.collection(_collectionName).doc(pedidoId).snapshots()
        .map((doc) {
          if (!doc.exists) {
            // Puedes lanzar un error o devolver un Pedido nulo/por defecto si prefieres
            // Para Riverpod, es mejor que el stream emita un error si no existe el doc
            throw Exception('Pedido con ID $pedidoId no encontrado.');
          }
          return Pedido.fromFirestore(doc); // ¡Mapea el DocumentSnapshot a un Pedido!
        });
  }


  // 4. Método para AÑADIR un nuevo pedido
  Future<void> addPedido(Map<String, dynamic> data) async {
    // Puedes añadir un timestamp de creación aquí si lo deseas
    data['fecha'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collectionName).add(data);
  }

  // 5. Método para ACTUALIZAR un pedido existente
  Future<void> updatePedido(String pedidoId, Map<String, dynamic> data) async {
    // Puedes añadir un timestamp de última actualización aquí
    data['ultimaActualizacion'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collectionName).doc(pedidoId).update(data);
  }

  // 6. Método para BORRAR un pedido
  Future<void> deletePedido(String pedidoId) async {
    await _firestore.collection(_collectionName).doc(pedidoId).delete();
  }
}

// Provider que expone el PedidosService
final pedidosServiceProvider = Provider<PedidosService>((ref) {
  final firestore = ref.read(firestoreProvider);
  return PedidosService(firestore);
});