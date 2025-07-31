// lib/models/usuario_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;      // UID de Firebase Authentication
  final String nombre;   // Nombre del usuario
  final String correo;   // Email del usuario
  final String? role;     // Rol del usuario (ej: 'admin', 'camarero', 'cocinero')

  Usuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    this.role,
  });

  // Factory constructor para crear un objeto Usuario desde un DocumentSnapshot de Firestore
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Puede ser nulo si el documento no existe

    if (data == null) {
      throw StateError('El documento del usuario no existe o está vacío');
    }

    return Usuario(
      uid: doc.id, // El ID del documento es el UID del usuario
      nombre: data['name'] as String? ?? 'Usuario Desconocido', // Asume que en Firestore se guarda como 'name'
      correo: data['email'] as String? ?? 'sin_correo@ejemplo.com', // Asume que en Firestore se guarda como 'email'
      role: data['role'] as String?, // Asume que en Firestore se guarda como 'role'
    );
  }

  // Opcional: Método para convertir el objeto Usuario a un Map para guardarlo en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': nombre,
      'email': correo,
      if (role != null) 'role': role,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario &&
          runtimeType == other.runtimeType &&
          uid == other.uid; // Comparar usuarios por su UID

  @override
  int get hashCode => uid.hashCode;
}