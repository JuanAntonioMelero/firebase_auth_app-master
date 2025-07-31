// lib/widgets/menuDrawerCamarero.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ¡CAMBIO! Importa Usuario
import 'package:firebase_auth_app/routes/router.dart';
import 'package:firebase_auth_app/providers/auth_provider.dart';

class MenuDrawerCamarero extends ConsumerWidget {
  const MenuDrawerCamarero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ¡CAMBIO!: Observa usuarioStreamProvider
    final usuarioAsyncValue = ref.watch(usuarioStreamProvider);

    return Drawer(
      backgroundColor: const Color(0xFFE53935), // Color rojo de la imagen
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          
          // ¡CAMBIO!: Usa usuarioAsyncValue y el objeto Usuario
          usuarioAsyncValue.when(
            data: (usuario) {
              return UserAccountsDrawerHeader(
                
                accountName: Text(usuario?.nombre ?? 'Invitado'), // Usa usuario.nombre
                accountEmail: Text(usuario?.correo ?? 'correo@ejemplo.com'), // Usa usuario.correo
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
              color: Color(0xFFE53935), // Color rojo
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
              );
            },
            loading: () => UserAccountsDrawerHeader(
              accountName: const Text('Cargando...'),
              accountEmail: const Text(''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: CircularProgressIndicator(),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            error: (error, stack) => UserAccountsDrawerHeader(
              accountName: const Text('Error al cargar'),
              accountEmail: Text('Error: $error'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.error, color: Colors.red),
              ),
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              context.go(AppRoutes.home);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Pedidos Activos'),
            onTap: () {
              context.go(AppRoutes.home);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Tomar Nuevo Pedido'),
            onTap: () {
              context.go('${AppRoutes.home}/${AppRoutes.tomarPedido}');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Panel de Administración'),
            onTap: () {
              context.go(AppRoutes.adminHome);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go(AppRoutes.auth);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}