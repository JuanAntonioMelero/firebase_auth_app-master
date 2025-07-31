// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth_app/models/usuario_model.dart';
import 'package:firebase_auth_app/services/auth_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firebaseUserStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ¡CORRECCIÓN AQUÍ!: Cómo acceder al valor de firebaseUserStreamProvider
final usuarioStreamProvider = StreamProvider<Usuario?>((ref) async* {
  // Observa el AsyncValue, y Riverpod se encargará de re-ejecutar este provider
  // cuando firebaseUserStreamProvider cambie.
  // Accede directamente al '.value' del AsyncValue para obtener el User? real.
  final firebaseUser = ref.watch(firebaseUserStreamProvider).value; // <--- ¡CAMBIO CLAVE AQUÍ!

  if (firebaseUser == null) {
    // Si no hay usuario de Firebase (deslogueado), emite null AppUser
    yield null;
  } else {
    // Si hay un usuario de Firebase, usa el AuthService para obtener los datos de Usuario desde Firestore
    final authService = ref.read(authServiceProvider);
    final usuario = await authService.getUsuarioFromFirestore(firebaseUser.uid);
    yield usuario; // Emite el Usuario (o null si no se encontró en Firestore)
  }
});