// lib/home_screen.dart
// Elimina la definición del provider de aquí:
// final authServiceProvider = Provider<AuthService>((ref) => AuthService());

import 'package:firebase_auth_app/providers/auth_provider.dart';
import 'package:firebase_auth_app/screens/gestionUsusarios_screen.dart';
import 'package:firebase_auth_app/widgets/adminBuildCard.dart';
import 'package:firebase_auth_app/widgets/menuDrawerAdmin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importa el provider desde su nuevo archivo:
import 'package:firebase_auth_app/services/auth_service.dart'; // Todavía necesario si usas el tipo AuthService explícitamente

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos la instancia de AuthService desde el provider importado.
    final AuthService authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Administrador')),
      drawer: Drawer(
        child: menuDrawerAdmin(context, authService),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
          
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text('Gestionar usuarios'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestionUsuariosScreen(),
                  ),
                );
              },
            ),
                buildCard(context, 'Gestion de usuarios', Icons.security, '/permisos'),
                buildCard(context, 'Historial de pedidos', Icons.history, '/historial'),
                buildCard(context, 'Notificaciones locales', Icons.notifications, '/notificaciones'),
                buildCard(context, 'Exportar pedidos', Icons.picture_as_pdf, '/exportar'),
              ],
            ),
          ],
        ),
      ),
    );
  } 
}