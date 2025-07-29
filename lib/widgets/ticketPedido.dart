import 'package:flutter/material.dart';

class TicketPedido extends StatelessWidget {
  final String mesa;
  final int comensales;
  final DateTime fecha;
  final bool pagado;
  final List<Map<String, dynamic>> items;
  final double total;

  const TicketPedido({
    super.key,
    required this.mesa,
    required this.comensales,
    required this.fecha,
    required this.pagado,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('Restaurante Guzmán',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Divider(),
            Text('Mesa: $mesa'),
            Text('Comensales: $comensales'),
            Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'),
            Text('Pago: ${pagado ? "Pagado" : "Pendiente"}'),
            Divider(),
            ...items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item['nombre']} x${item['cantidad']}'),
                  Text('€${(item['precio'] * item['cantidad']).toStringAsFixed(2)}'),
                ],
              ),
            )),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('€${total.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}