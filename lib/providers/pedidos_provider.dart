
// StreamProvider para los pedidos de Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pedidosStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('pedidos')
      .orderBy('fecha', descending: true)
      .snapshots();
});