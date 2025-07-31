
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
