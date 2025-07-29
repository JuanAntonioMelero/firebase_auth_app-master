// lib/screens/home_screen.dart
import 'package:firebase_auth_app/models/user_model.dart';
import 'package:firebase_auth_app/providers/botton_navigator_provider.dart';
import 'package:firebase_auth_app/providers/pedidos_provider.dart';
import 'package:firebase_auth_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importa Riverpod
import 'package:firebase_auth/firebase_auth.dart'; // Importa el tipo User
import 'package:cloud_firestore/cloud_firestore.dart'; // Para QuerySnapshot

// Importa tus providers
import 'package:firebase_auth_app/providers/auth_provider.dart';

// Importa tus widgets y pantallas
import 'package:firebase_auth_app/screens/detallePedido.dart';
import 'package:firebase_auth_app/screens/tomar_pedido.dart';
import 'package:firebase_auth_app/widgets/menuDrawerCamarero.dart';
import 'package:firebase_auth_app/widgets/ordenBuildCard.dart';


// Cambiamos a ConsumerWidget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observar el usuario autenticado
    // Usamos .when para manejar los estados de AsyncValue (loading, error, data)
    final AsyncValue<User?> userAsyncValue = ref.watch(authStateChangesProvider);

    // 2. Observar el índice seleccionado de la barra inferior
    final int selectedIndex = ref.watch(bottomNavBarIndexProvider);

    // 3. Observar los pedidos de Firestore
    final AsyncValue<QuerySnapshot> pedidosAsyncValue = ref.watch(pedidosStreamProvider);

 // NUEVO: Observar los datos completos del usuario desde Firestore
    final AsyncValue<AppUser?> appUserAsyncValue = ref.watch(appUserProvider);





      // Determina el usuario actual para pasarlo al Drawer (ahora AppUser?)
    AppUser? currentAppUser;
    appUserAsyncValue.whenOrNull(
      data: (user) {
        currentAppUser = user;
        print(user);
      },
    );


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      // Pasa el usuario obtenido del provider al Drawer
      drawer: menuDrawerCamarero(currentAppUser!, context),
      body: Column(
        children: [
          // Sección superior (fondo amarillo)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 24.0,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFDD835), // Color amarillo de la imagen
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
                const Text(
                  'Ver pedidos',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TomarPedidoPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  label: const Text(
                    'Tomar pedido',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
          // Sección de pedidos activos
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
                    // Aquí usamos el resultado del StreamProvider de pedidos
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetallePedidoPage(pedidoId: pedido.id),
                                  ),
                                );
                              },
                              child: buildOrderCard(
                                mesa,
                                '$comensales comensales',
                                pedidoId,
                                context,
                              ),
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
        currentIndex: selectedIndex, // Usamos el valor del provider
        selectedItemColor: const Color(0xFF1976D2), // Azul
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Actualizamos el StateProvider al tocar un ítem
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
          // Aquí puedes añadir la lógica de navegación si es necesario
          // por ejemplo:
          // if (index == 0) {
          //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          // }
        },
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}