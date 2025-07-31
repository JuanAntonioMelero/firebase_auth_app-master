import 'package:firebase_auth_app/models/categoriaProducto_model.dart';
import 'package:firebase_auth_app/models/producto_model.dart';
import 'package:firebase_auth_app/providers/categoriasProductos_provider.dart';
import 'package:firebase_auth_app/providers/productos_provider.dart';
import 'package:firebase_auth_app/screens/PedidosEnTiempoReal.dart';
import 'package:firebase_auth_app/services/pedidos_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TomarPedidoPage extends ConsumerStatefulWidget {
  const TomarPedidoPage({super.key});

  @override
  ConsumerState<TomarPedidoPage> createState() => _TomarPedidoPageState();
}

class _TomarPedidoPageState extends ConsumerState<TomarPedidoPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<String> mesas = ['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];
  String? mesaSeleccionada;
  int comensales = 2;

  final List<String> categorias = [
    'Todos',
    // Las categorías reales se generarán dinámicamente
  ];
  String categoriaSeleccionada = 'Todos';
  
  final List<Map<String, dynamic>> pedidoActual = [];
  bool pedidoEnviado = false;


  // --- NUEVO: Lista para almacenar los productos del menú cargados desde Firebase ---
  List<Producto> productosDelMenu = [];


  void agregarAlPedido(Producto producto) {
        final index = pedidoActual.indexWhere((item) => item['nombre'] == producto.nombre);
    if (index != -1) {
      setState(() => pedidoActual[index]['cantidad'] += 1);
      _listKey.currentState!.setState(() {});
    } else {

      final newItem = {
        'id': producto.id, // Opcional, pero útil
        'nombre': producto.nombre,
        'precio': producto.precio,
        'cantidad': 1,
        'categoria': producto.categoria, // También útil para referencias futuras
      };
      pedidoActual.add(newItem);
      _listKey.currentState!.insertItem(pedidoActual.length - 1);
    }
  }

  void eliminarDelPedido(int index) {
    if (index < 0 || index >= pedidoActual.length) return; // Evita el error
    final removedItem = pedidoActual.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _buildResumenItem(removedItem, index, animation),
      duration: Duration(milliseconds: 300),
    );
  }

  void enviarPedido() async {
    if (mesaSeleccionada == null || pedidoActual.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona una mesa y al menos un plato')),
      );
      return;
    }

    setState(() => pedidoEnviado = true);
 // Calcula el total antes de enviar
    double totalPedido = pedidoActual.fold<double>(
      0.0,
      (sum, item) => sum + (item['precio'] * item['cantidad']),
    );

    final Map<String, dynamic> nuevoPedidoData = {
      'mesa': mesaSeleccionada,
      'comensales': comensales,
      'estado': 'pendiente',
      // 'fecha' se establecerá automáticamente en el servicio con FieldValue.serverTimestamp()
      'items': pedidoActual,
      'pagado': false,
      'total': totalPedido, // Agrega el total aquí
    };

        // --- CAMBIO CLAVE 4: Usar Riverpod para llamar al servicio ---
    final pedidosService = ref.read(pedidosServiceProvider);

try {
      await pedidosService.addPedido(nuevoPedidoData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado correctamente')),
      );

      // Limpiar el pedido actual después de enviar
      setState(() {
        pedidoActual.clear();
        pedidoEnviado = false;
        // Si _listKey.currentState es nulo, no intentes llamar a setState en él.
        // Opcional: _listKey.currentState!.setState(() {}); si AnimatedList necesita forzar el rebuild.
      });

      // Opcional: Navegar a alguna pantalla o cerrar el modal
      // Navigator.pop(context); // Si TomarPedidoPage es un modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el pedido: $e')),
      );
      setState(() {
        pedidoEnviado = false; // Restablecer el estado del botón si hay un error
      });
    }

    
  }

  Widget _buildResumenItem(
    Map<String, dynamic> item,
    int index,
    Animation<double> animation,
  ) {
    final imagen = productosDelMenu.firstWhere(
      (producto) => producto.nombre == item['nombre'],
      orElse: () => Producto( // Devuelve un producto por defecto si no se encuentra (para evitar errores)
        id: '', nombre: item['nombre'], precio: 0.0, categoria: '', imagen: 'https://via.placeholder.com/150',
      ),
    ).imagen;
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Colors.orange.shade100,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imagen,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text('${item["nombre"]} x${item["cantidad"]}'),
          subtitle: Text(
            '€${(item["precio"] * item["cantidad"]).toStringAsFixed(2)}',
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => eliminarDelPedido(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Producto>> productosAsyncValue = ref.watch(productosStreamProvider);
    final AsyncValue<List<CategoriaProducto>> categoriasAsyncValue = ref.watch(categoriasStreamProvider);


    return Scaffold(
      appBar: AppBar(
        title: Text('Tomar pedido'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PedidosEnTiempoRealPage(),
                ),
              );
            },
          ),
        ],
      ),
     body: productosAsyncValue.when(
        data: (productos) {
          productosDelMenu = productos;

          return categoriasAsyncValue.when(
            data: (categoriasObj) { // Ahora recibimos objetos CategoriaProducto
              final List<String> categoriasNombres = ['Todos', ...categoriasObj.map((cat) => cat.nombre)];
              // Asegurarse de que categoriaSeleccionada es una de las opciones válidas
              if (!categoriasNombres.contains(categoriaSeleccionada)) {
                categoriaSeleccionada = 'Todos';
              }

              final platosFiltrados = categoriaSeleccionada == 'Todos'
                  ? productosDelMenu
                  : productosDelMenu
                        .where((producto) => producto.categoria == categoriaSeleccionada)
                        .toList();

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Mesa',
                              border: OutlineInputBorder(),
                            ),
                            value: mesaSeleccionada,
                            items: mesas
                                .map(
                                  (mesa) =>
                                      DropdownMenuItem(value: mesa, child: Text(mesa)),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => mesaSeleccionada = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Comensales',
                              border: OutlineInputBorder(),
                            ),
                            value: comensales,
                            items: List.generate(12, (index) => index + 1)
                                .map(
                                  (num) =>
                                      DropdownMenuItem(value: num, child: Text('$num')),
                                )
                                .toList(),
                            onChanged: (value) => setState(() => comensales = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: categoriaSeleccionada,
                      items: categoriasNombres // ¡Usar los NOMBRES de las categorías!
                          .map((catNombre) => DropdownMenuItem(value: catNombre, child: Text(catNombre)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => categoriaSeleccionada = value!),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: platosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = platosFiltrados[index];
                          return Card(
                            color: Colors.orange.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  producto.imagen,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(producto.nombre),
                              subtitle: Text('€${producto.precio.toStringAsFixed(2)}'),
                              trailing: GestureDetector(
                                onTap: () =>
                                    agregarAlPedido(producto),
                                child: const AnimatedScale(
                                  scale: 1.1,
                                  duration: Duration(milliseconds: 150),
                                  child: Icon(Icons.add_circle, color: Colors.green),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Resumen del pedido',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 160,
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount: pedidoActual.length,
                        itemBuilder: (context, index, animation) {
                          if (index < 0 || index >= pedidoActual.length) {
                            return const SizedBox.shrink();
                          }
                          return _buildResumenItem(
                            pedidoActual[index],
                            index,
                            animation,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pedidoEnviado
                              ? Colors.green
                              : Colors.deepOrange,
                        ),
                        onPressed: enviarPedido,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: pedidoEnviado
                              ? const Icon(
                                  Icons.check_circle,
                                  key: ValueKey('check'),
                                  size: 28,
                                )
                              : const Text('Enviar pedido', key: ValueKey('text')),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error al cargar categorías: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error al cargar productos: $error')),
      ),
     );
  }
}
