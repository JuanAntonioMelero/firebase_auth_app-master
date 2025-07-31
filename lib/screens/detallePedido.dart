import 'package:firebase_auth_app/models/pedido_model.dart';
import 'package:firebase_auth_app/providers/pedidos_provider.dart';
import 'package:firebase_auth_app/widgets/generarTicketPDF.dart';
import 'package:firebase_auth_app/widgets/ticketPedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importar Riverpod

// --- Importar tu servicio y providers de pedidos ---
import 'package:firebase_auth_app/services/pedidos_service.dart';

// DetallePedidoPage ya es ConsumerStatefulWidget, perfecto para Riverpod
class DetallePedidoPage extends ConsumerStatefulWidget {
  final String pedidoId;

  const DetallePedidoPage({super.key, required this.pedidoId});

  @override
  ConsumerState<DetallePedidoPage> createState() => _DetallePedidoPageState();
}

class _DetallePedidoPageState extends ConsumerState<DetallePedidoPage> {
  // --- ELIMINAR: _pedidoFuture ya no es necesario ---
  // late Future<DocumentSnapshot> _pedidoFuture;

  @override
  void initState() {
    super.initState();
    // --- ELIMINAR: initState ya no es necesario para inicializar Future ---
    // _pedidoFuture = FirebaseFirestore.instance
    //     .collection('pedidos')
    //     .doc(widget.pedidoId)
    //     .get();
  }

  // --- No necesitamos un dispose para el Future, pero si usaras un StreamController manual, lo necesitarías ---

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar pedido?'),
        content: const Text(
          'Esta acción no se puede deshacer. ¿Estás seguro de que quieres eliminar este pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final pedidosService = ref.read(pedidosServiceProvider);
              try {
                await pedidosService.deletePedido(widget.pedidoId);

                // Después de eliminar, la UI se actualizará automáticamente si tienes
                // una lista de pedidos con StreamProvider. Aquí simplemente volvemos.
                Navigator.pop(context); // Cierra el diálogo de confirmación
                Navigator.pop(context); // Vuelve a la pantalla anterior (lista de pedidos)

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pedido eliminado correctamente')),
                );
              } catch (e) {
                Navigator.pop(context); // Cierra el diálogo de confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar el pedido: $e')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> marcarComoPagado() async {
    final pedidosService = ref.read(pedidosServiceProvider);
    try {
      await pedidosService.updatePedido(widget.pedidoId, {'pagado': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido marcado como pagado')),
      );

      // --- IMPORTANTE: Ya NO necesitas setState o refrescar _pedidoFuture aquí ---
      // El StreamProvider automáticamente detectará el cambio en Firestore
      // y reconstruirá el widget con los datos actualizados.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como pagado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- CAMBIO CLAVE: Usar ref.watch para escuchar el StreamProvider ---
    final AsyncValue<Pedido> pedidoAsyncValue = ref.watch(pedidoByIdStreamProvider(widget.pedidoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del pedido'),
        backgroundColor: Colors.deepOrange,
      ),
      body: pedidoAsyncValue.when(
        data: (pedido) {
          // --- CAMBIO CLAVE: Manejo del estado si el documento no existe ---
         // if (!pedido.exists) {
         //   return const Center(child: Text('Pedido no encontrado. Puede que haya sido eliminado.'));
         // }

          final mesa = pedido.mesa;
          final comensales = pedido.comensales;
          final estado = pedido.estado;
          final pagado = pedido.pagado == true;
          final fecha = pedido.fecha;
          final items = List<Map<String, dynamic>>.from(pedido.items);
          final total = items.fold<double>(
            0.0,
            (sum, item) => sum + (item['precio'] * item['cantidad']),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado: $estado', style: const TextStyle(fontSize: 18)),
                  Text(
                    'Pago: ${pagado ? "Pagado" : "Pendiente"}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Hora: ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // ... (otros detalles del pedido) ...

                  const SizedBox(height: 10),
                  Text(
                    'Total: €${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TicketPedido(
                    mesa: mesa,
                    comensales: comensales,
                    fecha: fecha,
                    pagado: pagado,
                    items: items,
                    total: total,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    onPressed: () => generarTicketPDF(
                      mesa: mesa,
                      comensales: comensales,
                      fecha: fecha,
                      pagado: pagado,
                      items: items,
                      total: total,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar pedido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmarEliminacion(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!pagado)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text('Marcar como pagado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: marcarComoPagado,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error al cargar el pedido: $error')),
      ),
    );
  }
}

// ... (tu función generarTicketPDF permanece igual) ...