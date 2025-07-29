import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidosEnTiempoRealPage extends StatefulWidget {
  const PedidosEnTiempoRealPage({super.key});

  @override
  State<PedidosEnTiempoRealPage> createState() =>
      _PedidosEnTiempoRealPageState();
}

class _PedidosEnTiempoRealPageState extends State<PedidosEnTiempoRealPage> {
  String? mesaSeleccionada;
  String estadoSeleccionado = 'Todos';

  final List<String> estados = ['Todos', 'pendiente', 'preparación', 'servido'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos en tiempo real'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filtrar por mesa',
                      border: OutlineInputBorder(),
                    ),
                    value: mesaSeleccionada,
                    items: [null, 'Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4']
                        .map(
                          (mesa) => DropdownMenuItem(
                            value: mesa,
                            child: Text(mesa ?? 'Todas'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => mesaSeleccionada = value),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    value: estadoSeleccionado,
                    items: estados
                        .map(
                          (estado) => DropdownMenuItem(
                            value: estado,
                            child: Text(estado),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => estadoSeleccionado = value!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar pedidos'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var pedidos = snapshot.data!.docs;

                // 🔍 Aplicar filtros
                pedidos = pedidos.where((pedido) {
                  final mesa = pedido['mesa'];
                  final estado = pedido['estado'];
                  final mesaOk =
                      mesaSeleccionada == null || mesa == mesaSeleccionada;
                  final estadoOk =
                      estadoSeleccionado == 'Todos' ||
                      estado == estadoSeleccionado;
                  return mesaOk && estadoOk;
                }).toList();

                if (pedidos.isEmpty) {
                  return Center(child: Text('No hay pedidos que coincidan'));
                }

                return ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    final mesa = pedido['mesa'];
                    final comensales = pedido['comensales'];
                    final estado = pedido['estado'];
                    final fecha = (pedido['fecha'] as Timestamp).toDate();
                    final items = List<Map<String, dynamic>>.from(
                      pedido['items'],
                    );

                    return Card(
                      margin: EdgeInsets.all(8),
                      color: Colors.orange.shade50,
                      child: ListTile(
                        title: Text('Mesa: $mesa ($comensales comensales)'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado: $estado'),
                            Text(
                              'Hora: ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                            ),
                            ...items.map(
                              (item) => Text(
                                '${item['nombre']} x${item['cantidad']} - €${(item['precio'] * item['cantidad']).toStringAsFixed(2)}',
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (nuevoEstado) =>
                              actualizarEstado(pedido.id, nuevoEstado),
                          itemBuilder: (context) =>
                              ['pendiente', 'preparación', 'servido']
                                  .map(
                                    (estado) => PopupMenuItem(
                                      value: estado,
                                      child: Text('Marcar como "$estado"'),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void actualizarEstado(String pedidoId, String nuevoEstado) async {
    await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).update(
      {'estado': nuevoEstado},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estado actualizado a "$nuevoEstado"')),
    );
  }
}
