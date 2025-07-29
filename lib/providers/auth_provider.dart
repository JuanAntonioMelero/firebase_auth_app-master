// lib/providers/app_providers.dart (o el nombre que prefieras)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_app/models/user_model.dart';
import 'package:firebase_auth_app/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para el tipo User

// Provider para AuthService (si no lo tenías ya)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// StreamProvider para el estado de autenticación del usuario.
// Este provider emitirá un nuevo User? cada vez que el estado de autenticación cambie.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  // Observa el servicio de autenticación y devuelve su stream de cambios de estado.
  return ref.watch(authServiceProvider).authStateChanges;
});
