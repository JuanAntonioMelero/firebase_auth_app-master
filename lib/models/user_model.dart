// lib/models/app_user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? name; // Por ejemplo, si tienes un campo 'name'
  final String? role; // Por ejemplo, si tienes un campo 'role'
  // Añade aquí cualquier otro campo que tengas en tu documento de usuario en Firestore

  AppUser({
    required this.uid,
    this.email,
    this.name,
    this.role,
  });

  // Factory constructor para crear una instancia de AppUser desde un DocumentSnapshot
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return AppUser(
      uid: doc.id, // El UID es el ID del documento en Firestore
      email: data?['email'] as String?,
      name: data?['name'] as String?,
      role: data?['role'] as String?,
      // Mapea aquí tus otros campos
    );
  }

  // Opcional: Para convertir AppUser a un mapa si necesitas guardarlo de nuevo
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }
}