import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> crearUsuarioConRol(String email, String password, String rol, String name) async {
  try {
    // Crear usuario en Firebase Auth
    UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Obtener UID
    String uid = cred.user!.uid;

    // Guardar rol en Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'role': rol,
      'displayName!': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('id del usurio: $uid');
    print('Usuario creado con rol: $rol');
  } catch (e) {
    print('Error al crear usuario: $e');
  }
}
