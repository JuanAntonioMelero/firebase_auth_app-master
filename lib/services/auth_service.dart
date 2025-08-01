// lib/services/auth_service.dart
// Este archivo contiene la lógica para interactuar con Firebase Authentication.
// Proporciona métodos para registrar, iniciar sesión y cerrar sesión.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_app/models/usuario_model.dart';

class AuthService {
  // Instancia de FirebaseAuth para interactuar con el servicio de autenticación.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instancia de FirebaseFirestore para interactuar con la base de datos Firestore.
  // ¡Ahora _firestore se inicializa en el constructor!
  final FirebaseFirestore _firestore;

  // Constructor de la clase AuthService
  AuthService() : _firestore = FirebaseFirestore.instance; // <--- ¡Esta es la clave!

  // Este getter expone el stream de cambios de estado de autenticación de Firebase.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método para registrar un nuevo usuario con email y contraseña.
  // Retorna el objeto User si el registro es exitoso, de lo contrario null.
  Future<User?> signUp(String email, String password) async {
    try {
      // Intenta crear un nuevo usuario con el email y la contraseña proporcionados.
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Retorna el usuario creado.
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Captura y maneja excepciones específicas de FirebaseAuth.
      print('Error de registro: ${e.message}');
      // Retorna null si ocurre un error.
      return null;
    } catch (e) {
      // Captura cualquier otra excepción.
      print('Error inesperado durante el registro: $e');
      return null;
    }
  }

  // Método para iniciar sesión con email y contraseña.
  // Retorna el objeto User si el inicio de sesión es exitoso, de lo contrario null.
  Future<User?> signIn(String email, String password) async {
    try {
      // Intenta iniciar sesión con el email y la contraseña proporcionados.
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Retorna el usuario que ha iniciado sesión.
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Captura y maneja excepciones específicas de FirebaseAuth.
      print('Error de inicio de sesión: ${e.message}');
      // Retorna null si ocurre un error.
      return null;
    } catch (e) {
      // Captura cualquier otra excepción.
      print('Error inesperado durante el inicio de sesión: $e');
      return null;
    }
  }

  // Método para cerrar la sesión del usuario actual.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Obtiene el usuario actualmente autenticado.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Un stream que emite el usuario actual cada vez que cambia el estado de autenticación.
  // Útil para escuchar cambios en tiempo real en la UI.
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Método para obtener los detalles de Usuario desde Firestore
  Future<Usuario?> getUsuarioFromFirestore(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        // Asegúrate de que el constructor Usuario.fromFirestore acepte un DocumentSnapshot
        return Usuario.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      print('Error al obtener Usuario desde Firestore para $uid: $e');
      return null;
    }
  }
}