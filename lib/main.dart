// main.dart
// Este es el punto de entrada de la aplicación Flutter.
// Inicializa Firebase y muestra la vista adecuada según el estado de autenticación y el rol del usuario.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/adminHome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            final uid = snapshot.data!.uid;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, roleSnapshot) {
                if (!roleSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = roleSnapshot.data!.data() as Map<String, dynamic>?;
                final role = data?['role'] ?? 'guest';

                switch (role) {
                  case 'admin':
                    return AdminHomeScreen();
                  case 'user':
                    return HomeScreen();
                  default:
                    return const Scaffold(
                      body: Center(child: Text('Rol no reconocido')),
                    );
                }
              },
            );
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
