import 'package:firebase_auth_app/screens/PedidosEnTiempoReal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TomarPedidoPage extends StatefulWidget {
  const TomarPedidoPage({super.key});

  @override
  _TomarPedidoPageState createState() => _TomarPedidoPageState();
}

class _TomarPedidoPageState extends State<TomarPedidoPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<String> mesas = ['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];
  String? mesaSeleccionada;
  int comensales = 2;

  final List<String> categorias = [
    'Todos',
    'Entrantes',
    'Platos',
    'Postres',
    'Bebidas',
  ];
  String categoriaSeleccionada = 'Todos';

  final List<Map<String, dynamic>> menu = [
    {
      'nombre': 'Pizza Margarita',
      'precio': 8.5,
      'categoria': 'Platos',
      'imagen': 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092',
    },
    {
      'nombre': 'Ensalada César',
      'precio': 6.0,
      'categoria': 'Entrantes',
      'imagen': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7',
    },
    {
      'nombre': 'Hamburguesa BBQ',
      'precio': 9.0,
      'categoria': 'Platos',
      'imagen': 'https://images.unsplash.com/photo-1550547660-d9450f859349',
    },
    {
      'nombre': 'Tarta de queso',
      'precio': 4.5,
      'categoria': 'Postres',
      'imagen': 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092',
    },
    {
      'nombre': 'Limonada fresca',
      'precio': 3.0,
      'categoria': 'Bebidas',
      'imagen': 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092',
    },
  ];

  final List<Map<String, dynamic>> pedidoActual = [];
  bool pedidoEnviado = false;

  void agregarAlPedido(String nombre, double precio) {
    final index = pedidoActual.indexWhere((item) => item['nombre'] == nombre);
    if (index != -1) {
      setState(() => pedidoActual[index]['cantidad'] += 1);
      _listKey.currentState!.setState(() {});
    } else {
      final newItem = {'nombre': nombre, 'precio': precio, 'cantidad': 1};
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

    final pedido = {
      'mesa': mesaSeleccionada,
      'comensales': comensales,
      'estado': 'pendiente',
      'fecha': Timestamp.now(),
      'items': pedidoActual,
      'pagado': false,
    };

    await FirebaseFirestore.instance.collection('pedidos').add(pedido);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Pedido enviado a Firebase')));

    setState(() {
      pedidoActual.clear();
      pedidoEnviado = false;
      _listKey.currentState!.setState(() {});
    });
  }

  Widget _buildResumenItem(
    Map<String, dynamic> item,
    int index,
    Animation<double> animation,
  ) {
    final imagen = menu.firstWhere(
      (plato) => plato['nombre'] == item['nombre'],
    )['imagen'];
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
    final platosFiltrados = categoriaSeleccionada == 'Todos'
        ? menu
        : menu
              .where((plato) => plato['categoria'] == categoriaSeleccionada)
              .toList();

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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
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
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
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
            SizedBox(height: 10),
            DropdownButton<String>(
              value: categoriaSeleccionada,
              items: categorias
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => categoriaSeleccionada = value!),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: platosFiltrados.length,
                itemBuilder: (context, index) {
                  final plato = platosFiltrados[index];
                  return Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          plato['imagen'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(plato['nombre']),
                      subtitle: Text('€${plato['precio']}'),
                      trailing: GestureDetector(
                        onTap: () =>
                            agregarAlPedido(plato['nombre'], plato['precio']),
                        child: AnimatedScale(
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
            SizedBox(height: 10),
            Text(
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
                    return SizedBox.shrink();
                  }
                  return _buildResumenItem(
                    pedidoActual[index],
                    index,
                    animation,
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
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
                  duration: Duration(milliseconds: 500),
                  child: pedidoEnviado
                      ? Icon(
                          Icons.check_circle,
                          key: ValueKey('check'),
                          size: 28,
                        )
                      : Text('Enviar pedido', key: ValueKey('text')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
