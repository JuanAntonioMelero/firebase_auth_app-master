import 'package:firebase_auth_app/services/auth_service.dart';
import 'package:flutter/material.dart';


ListView menuDrawerAdmin(BuildContext context, AuthService authService) {
    return ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Pedidos'),
            onTap: () => Navigator.pushNamed(context, '/pedidos'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial'),
            onTap: () => Navigator.pushNamed(context, '/historial'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Permisos'),
            onTap: () => Navigator.pushNamed(context, '/permisos'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            onTap: () => Navigator.pushNamed(context, '/notificaciones'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Exportar pedidos'),
            onTap: () => Navigator.pushNamed(context, '/exportar'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            onTap: () async {
              Navigator.pop(context); // Cierra el drawer primero
              await authService.signOut();
            },
          ),
        ],
      );
  }
