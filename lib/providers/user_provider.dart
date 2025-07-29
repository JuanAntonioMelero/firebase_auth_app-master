
// NUEVO: Provider para los datos completos del usuario desde Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_app/models/user_model.dart';
import 'package:firebase_auth_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appUserProvider = StreamProvider<AppUser?>((ref) {
  // Observa los cambios de autenticación
  final authUser = ref.watch(authStateChangesProvider);

  return authUser.when(
    data: (user) {
      if (user == null) {
        // Si no hay usuario autenticado, devuelve un stream con null
        return Stream.value(null);
      } else {
        // Si hay un usuario, escucha su documento en Firestore
        return FirebaseFirestore.instance
            .collection('users') // Asegúrate que el nombre de la colección es correcto
            .doc(user.uid)
            .snapshots()
            .map((snapshot) {
              if (snapshot.exists) {
                return AppUser.fromFirestore(snapshot);
              } else {
                // El documento del usuario no existe en Firestore
                print('Advertencia: Documento de usuario ${user.uid} no encontrado en Firestore.');
                return null;
              }
            });
      }
    },
    loading: () => Stream.value(null), // Mientras carga la autenticación, no hay usuario
    error: (err, stack) {
      print('Error en authStateChangesProvider: $err');
      return Stream.value(null); // En caso de error, devuelve null
    },
  );
});