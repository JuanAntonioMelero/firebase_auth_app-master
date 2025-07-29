import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_app/models/user_model.dart';
import 'package:firebase_auth_app/services/auth_service.dart';
import 'package:flutter/material.dart';

  final AuthService _auth = AuthService();


Drawer menuDrawerCamarero( AppUser user, BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE53935), // Color rojo de la imagen
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFE53935), // Color rojo
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                Text(
                  user.name ?? 'Usuario',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.white),
            title: const Text(
              'Menú',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              // Manejar el toque en el menú
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.white),
            title: const Text(
              'Reservas',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
              // Manejar el toque en reservas
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.white),
            title: const Text(
              'Pedido',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
              // Manejar el toque en pedido
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: const Text(
              'Perfil',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
              // Manejar el toque en perfil
            },
          ),
          const Divider(color: Colors.white54),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onTap: () async {
              Navigator.pop(context); // Cierra el drawer primero
              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }
