
// StateProvider para el índice seleccionado de la BottomNavigationBar.
// Usamos StateProvider para un estado simple que se puede modificar directamente.
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavBarIndexProvider = StateProvider<int>((ref) => 1); // Índice inicial 1 (Pedidos)


