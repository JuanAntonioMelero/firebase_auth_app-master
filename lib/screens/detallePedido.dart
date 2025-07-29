import 'package:firebase_auth_app/widgets/ticketPedido.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DetallePedidoPage extends StatefulWidget {
  final String pedidoId;

  const DetallePedidoPage({super.key, required this.pedidoId});

  @override
  State<DetallePedidoPage> createState() => _DetallePedidoPageState();
}

class _DetallePedidoPageState extends State<DetallePedidoPage> {
  late Future<DocumentSnapshot> _pedidoFuture;

  @override
  void initState() {
    super.initState();
    _pedidoFuture = FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.pedidoId)
        .get();
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar pedido?'),
        content: Text(
          'Esta acción no se puede deshacer. ¿Estás seguro de que quieres eliminar este pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('pedidos')
                  .doc(widget.pedidoId)
                  .delete();

              Navigator.pop(context); // Cierra el diálogo
              Navigator.pop(context); // Vuelve a la pantalla anterior

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Pedido eliminado')));
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> marcarComoPagado() async {
    await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.pedidoId)
        .update({'pagado': true});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Pedido marcado como pagado')));

    setState(() {
      _pedidoFuture = FirebaseFirestore.instance
          .collection('pedidos')
          .doc(widget.pedidoId)
          .get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del pedido'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _pedidoFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el pedido'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final pedido = snapshot.data!;
          final mesa = pedido['mesa'];
          final comensales = pedido['comensales'];
          final estado = pedido['estado'];
          final pagado = pedido['pagado'] == true;
          final fecha = (pedido['fecha'] as Timestamp).toDate();
          final items = List<Map<String, dynamic>>.from(pedido['items']);
          final total = items.fold<double>(
            0.0,
            (sum, item) => sum + item['precio'] * item['cantidad'],
          );

          return Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado: $estado', style: TextStyle(fontSize: 18)),
                  Text(
                    'Pago: ${pagado ? "Pagado" : "Pendiente"}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Hora: ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),

                  SizedBox(height: 10),
                  Text(
                    'Total: €${total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TicketPedido(
                    mesa: mesa,
                    comensales: comensales,
                    fecha: fecha,
                    pagado: pagado,
                    items: items,
                    total: total,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('Generar PDF'),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('Eliminar pedido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmarEliminacion(context),
                    ),
                  ),
                  if (!pagado)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.payment),
                        label: Text('Marcar como pagado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: marcarComoPagado,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> generarTicketPDF({
  required String mesa,
  required int comensales,
  required DateTime fecha,
  required bool pagado,
  required List<Map<String, dynamic>> items,
  required double total,
}) async {
  final pdf = pw.Document();
  final font = await PdfGoogleFonts.openSansRegular(); // Carga la fuente

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(210 * PdfPageFormat.mm, 100 * PdfPageFormat.mm),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Restaurante Guzmán',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 4),
          pw.Text('Mesa: $mesa'),
          pw.Text('Comensales: $comensales'),
          pw.Text(
            'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
          ),
          pw.Text('Pago: ${pagado ? "Pagado" : "Pendiente"}'),
          pw.SizedBox(height: 10),
          pw.Text(
            'Platos pedidos:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Plato',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Cant.',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Precio',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...items.map(
                (item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text(item['nombre']),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text('${item['cantidad']}'),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text('€${item['precio'].toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text(
                        '€${(item['precio'] * item['cantidad']).toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            color: PdfColors.grey200,
            padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '€${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
