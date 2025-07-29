// lib/widgets/adminBuildCard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importa go_router para la navegación

// Asumiendo que esta función se utiliza en el contexto de admin (como HomeScreenAdmin)
// Y que las rutas están definidas en AppRoutes
// Si quieres que reciba un AppUser para alguna logica interna, también puedes pasarlo
// Widget buildCard(BuildContext context, String title, IconData icon, String route, {AppUser? user}) {
Widget buildCard(BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      // Cambiamos Navigator.pushNamed por context.go para usar go_router
      onTap: () => context.go(route), // Usamos context.go(route)
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Opcional: bordes redondeados
        child: Container(
          width: 150,
          // Mantendremos la altura fija, pero haremos que el contenido se ajuste
          height: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // Centramos el contenido horizontalmente
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              // *** MODIFICACIÓN CLAVE AQUÍ: Manejo del Texto ***
              Expanded( // Envuelve el Text en un Expanded
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2, // Permite hasta 2 líneas de texto
                  overflow: TextOverflow.ellipsis, // Si el texto es más largo, muestra "..."
                  style: const TextStyle(
                    fontSize: 14, // Ajusta el tamaño de la fuente si es necesario
                    fontWeight: FontWeight.bold, // Para que resalte
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }