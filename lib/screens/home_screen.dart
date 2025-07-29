// lib/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_app/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import go_router

// Import your models, providers, routes, and widgets
import 'package:firebase_auth_app/models/user_model.dart';
import 'package:firebase_auth_app/providers/user_provider.dart'; // For appUserProvider
import 'package:firebase_auth_app/providers/pedidos_provider.dart'; // For pedidosStreamProvider
import 'package:firebase_auth_app/providers/botton_navigator_provider.dart'; // Assuming this is your bottom nav index provider

import 'package:firebase_auth_app/widgets/menuDrawerCamarero.dart'; // Your custom drawer

// Convert to ConsumerWidget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the appUserProvider for user data
    final AsyncValue<AppUser?> appUserAsyncValue = ref.watch(appUserProvider);

    // Watch the bottom navigation bar index provider
    final int selectedIndex = ref.watch(bottomNavBarIndexProvider);

    // Watch the pedidos stream provider
    final AsyncValue<QuerySnapshot> pedidosAsyncValue = ref.watch(pedidosStreamProvider);

    // Handle the appUserAsyncValue states (loading, error, data)
    return appUserAsyncValue.when(
      data: (appUser) {
        // If appUser is null, you might want to redirect to auth screen
        // This scenario should ideally be handled by go_router's redirect,
        // but it's good to have a fallback.
        if (appUser == null) {
          // If for some reason we land here without a user, redirect.
          WidgetsBinding.instance.addPostFrameCallback((_) {
             context.go(AppRoutes.auth);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: null, // Custom AppBar in Column
          // Pass appUser to the drawer, which now expects AppUser?
          drawer: menuDrawerCamarero(appUser, context),
          body: Column(
            children: [
              // Top section (yellow background)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDD835),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display user's name from AppUser model
                    Text(
                      'Hola, ${appUser.name}', // Use appUser.nombre directly
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate using go_router
                        context.go(AppRoutes.home + '/' + AppRoutes.tomarPedido); // Full path /home/tomar-pedido
                      },
                      icon: const Icon(Icons.edit_note, color: Colors.white),
                      label: const Text(
                        'Tomar pedido',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
              // Active orders section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pedidos activos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Expanded(
                        // Use AsyncValue.when for the pedidosStreamProvider
                        child: pedidosAsyncValue.when(
                          data: (QuerySnapshot snapshot) {
                            final pedidos = snapshot.docs;

                            if (pedidos.isEmpty) {
                              return const Center(child: Text('No hay pedidos activos'));
                            }

                            return ListView.builder(
                              itemCount: pedidos.length,
                              itemBuilder: (context, index) {
                                final pedido = pedidos[index];
                                final mesa = pedido['mesa'];
                                final comensales = pedido['comensales'];
                                final pedidoId = pedido.id;

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate using go_router with a parameter
                                    context.go('${AppRoutes.home}/${AppRoutes.detallePedido}/$pedidoId');
                                  },
                                  child: _buildOrderCard(mesa, '$comensales comensales', pedidoId, context),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(child: Text('Error al cargar pedidos: $error')),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Pedidos'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: const Color(0xFF1976D2),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              ref.read(bottomNavBarIndexProvider.notifier).state = index;
              // Optional: Add go_router navigation for bottom nav items if they lead to different top-level routes
              // For example:
              // if (index == 0) { context.go(AppRoutes.home); }
              // else if (index == 1) { context.go('/some-other-pedidos-route'); }
              // else if (index == 2) { context.go('/user-profile'); }
            },
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error de Usuario')),
        body: Center(child: Text('Error al cargar datos del usuario: $error')),
      ),
    );
  }

  // Refactor _buildOrderCard to accept BuildContext and use it for go_router navigation
  Widget _buildOrderCard(String table, String diners, String pedidoId, BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('${AppRoutes.home}/${AppRoutes.detallePedido}/$pedidoId');
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFFE53935),
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      diners,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}