// lib/config/router.dart
import 'package:firebase_auth_app/screens/adminHome_screen.dart';
import 'package:firebase_auth_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importa tus pantallas
import 'package:firebase_auth_app/screens/home_screen.dart';
import 'package:firebase_auth_app/screens/detallePedido.dart';
import 'package:firebase_auth_app/screens/tomar_pedido.dart';
import 'package:firebase_auth_app/screens/gestionUsusarios_screen.dart';

// Importa tus providers de autenticación
import 'package:firebase_auth_app/providers/auth_provider.dart';
import 'package:firebase_auth_app/providers/user_provider.dart';

// Definimos los nombres de las rutas para fácil acceso
class AppRoutes {
  static const String auth = '/auth';
  static const String home = '/home';
  // Ruta completa para tomar-pedido (se llamará como /home/tomar-pedido)
  static const String tomarPedido = 'tomar-pedido'; // ¡Ahora es solo el segmento!
  static const String detallePedido = 'detalle-pedido'; // Nombre de sub-ruta
  static const String adminHome = '/admin'; // Ruta principal de admin
  // Nuevas rutas (solo segmentos, se combinarán con /admin)
  static const String gestionUsuarios = 'gestion-usuarios'; // ¡Ahora es solo el segmento!
  static const String adminPermisos = 'permisos'; // ¡Ahora es solo el segmento!
  static const String adminHistorial = 'historial'; // ¡Ahora es solo el segmento!
  static const String adminNotificaciones = 'notificaciones'; // ¡Ahora es solo el segmento!
  static const String adminExportar = 'exportar'; // ¡Ahora es solo el segmento!
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final appUserAsyncValue = ref.watch(appUserProvider);

  return GoRouter(
    initialLocation: AppRoutes.auth,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.tomarPedido, // Solo el segmento
            builder: (context, state) => TomarPedidoPage(),
          ),
          GoRoute(
            path: '${AppRoutes.detallePedido}/:pedidoId',
            builder: (context, state) {
              final pedidoId = state.pathParameters['pedidoId'];
              return DetallePedidoPage(pedidoId: pedidoId!);
            },
          ),
        ],
      ),
      // *** RUTAS DE ADMINISTRACIÓN ***
      GoRoute(
        path: AppRoutes.adminHome, // Ruta padre: /admin
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.gestionUsuarios, // ¡Solo el segmento "gestion-usuarios"!
            builder: (context, state) => GestionUsuariosScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminPermisos, // Solo el segmento "permisos"
            builder: (context, state) => const PlaceholderScreen(title: 'Gestión de Permisos'),
          ),
          GoRoute(
            path: AppRoutes.adminHistorial, // Solo el segmento "historial"
            builder: (context, state) => const PlaceholderScreen(title: 'Historial de Pedidos'),
          ),
          GoRoute(
            path: AppRoutes.adminNotificaciones, // Solo el segmento "notificaciones"
            builder: (context, state) => const PlaceholderScreen(title: 'Notificaciones Locales'),
          ),
          GoRoute(
            path: AppRoutes.adminExportar, // Solo el segmento "exportar"
            builder: (context, state) => const PlaceholderScreen(title: 'Exportar Pedidos'),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final currentAppUser = appUserAsyncValue.valueOrNull;

      final isGoingToProtectedRoute = state.matchedLocation.startsWith(AppRoutes.home) ||
                                     state.matchedLocation.startsWith(AppRoutes.adminHome);
      final isGoingToAuthRoute = state.matchedLocation == AppRoutes.auth;

      if (!isAuthenticated && isGoingToProtectedRoute) {
        return AppRoutes.auth;
      }

      if (isAuthenticated && appUserAsyncValue.isLoading) {
        return AppRoutes.auth; // O una pantalla de carga/splash
      }

      if (isAuthenticated && currentAppUser != null) {
        final isAdmin = currentAppUser.role == 'admin';

        if (isGoingToAuthRoute) {
          return isAdmin ? AppRoutes.adminHome : AppRoutes.home;
        }

        if (state.matchedLocation.startsWith(AppRoutes.adminHome) && !isAdmin) {
          return AppRoutes.home;
        }

        // Si un admin intenta ir a /home, lo redirigimos a /admin
        if (state.matchedLocation == AppRoutes.home && isAdmin) {
            return AppRoutes.adminHome;
        }
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
});

// PlaceholderScreen (si no la tienes definida ya)
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Contenido de la pantalla: $title', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}