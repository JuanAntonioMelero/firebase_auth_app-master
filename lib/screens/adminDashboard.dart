// lib/screens/admin_home_screen.dart
import 'package:firebase_auth_app/providers/pedidos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_app/providers/auth_provider.dart'; // Para AuthService
import 'package:firebase_auth_app/widgets/menuDrawerAdmin.dart'; // Tu Drawer existente
import 'package:fl_chart/fl_chart.dart'; // Importar fl_chart

// Definición de colores personalizados basados en tu solicitud
// Puedes ajustarlos con tu paleta de colores final
const Color kStrongRed = Color(0xFFD32F2F); // Un rojo fuerte (Material Red 700)
const Color kPastelYellow = Color(0xFFFFFBE0); // Un amarillo muy claro y suave

// 1. Crear un Widget para las tarjetas de resumen (Ventas, Pedidos, etc.)
class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor; // Para valores que necesitan destacar (ej. alertas)

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        // Ancho se maneja desde el padre (SizedBox en LayoutBuilder)
        // Altura se maneja desde el padre (SizedBox en LayoutBuilder)
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye espacio verticalmente
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea al inicio si el título es multilinea
              children: [
                Expanded( // Permite que el título ocupe el espacio restante
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 2, // Permite 2 líneas para títulos largos
                    overflow: TextOverflow.ellipsis, // ... si es más largo
                  ),
                ),
                Icon(icon, color: iconColor ?? Colors.black54, size: 24), // Color por defecto si no se especifica
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87, // Usa valueColor o un gris oscuro
              ),
              maxLines: 2, // Importante para el texto de "Pedidos"
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Widget para el gráfico de ventas (lo haremos estático por ahora, luego lo conectaremos a datos)
class SalesChartWidget extends StatefulWidget {
  const SalesChartWidget({super.key});

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  String _selectedPeriod = 'Semana'; // O 'Dia', 'Mes'

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ventas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildPeriodButton('Dia'),
                _buildPeriodButton('Semana'),
                _buildPeriodButton('Mes'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200, // Altura fija para el gráfico
              child: BarChart(
                BarChartData(
                  barGroups: _getBarGroups(_selectedPeriod),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _getBottomTitles,
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final bool isSelected = _selectedPeriod == period;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(period),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedPeriod = period;
            }
          });
        },
        selectedColor: kPastelYellow, // Usando el amarillo pastel para el seleccionado
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade900 : Colors.black87, // Azul oscuro para texto seleccionado
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(String period) {
    List<double> values;
    switch (period) {
      case 'Dia':
        values = [120, 150, 180, 100, 200];
        break;
      case 'Semana':
        values = [500, 650, 800, 700, 900, 600, 750];
        break;
      case 'Mes':
        values = [2000, 2500, 1800, 3000]; // Semanas
        break;
      default:
        values = [500, 650, 800, 700, 900, 600, 750];
        break;
    }

    return List.generate(values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            color: Colors.blue, // Color de las barras, puedes usar kStrongRed aquí si quieres
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [],
      );
    });
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final titles = {
      0: 'Lun', 1: 'Mar', 2: 'Mié', 3: 'Jue', 4: 'Vie', 5: 'Sáb', 6: 'Dom',
    };
    final dayTitles = {
      0: '8h', 1: '10h', 2: '12h', 3: '14h', 4: '16h',
    };
     final monthTitles = {
      0: 'Sem1', 1: 'Sem2', 2: 'Sem3', 3: 'Sem4',
    };

    String text;
    switch (_selectedPeriod) {
      case 'Dia':
        text = dayTitles[value.toInt()] ?? '';
        break;
      case 'Semana':
        text = titles[value.toInt()] ?? '';
        break;
      case 'Mes':
        text = monthTitles[value.toInt()] ?? '';
        break;
      default:
        text = '';
        break;
    }

    return SideTitleWidget(
      meta: meta,
      // Ya corregido: axisSide: meta.axisSide, ELIMINADO
      space: 4.0,
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 10)),
    );
  }
}

// 3. Widget para las listas de "Platos más vendidos", "Personal activo", etc.
class DashboardListCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items; // Ejemplo: [{'name': 'Pasta', 'value': '50 unidades', 'icon': Icons.food_bank}]
  final IconData defaultIcon;

  const DashboardListCard({
    super.key,
    required this.title,
    required this.items,
    this.defaultIcon = Icons.circle, // Icono por defecto si no se especifica en el item
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Usamos ListView.builder dentro de un SizedBox con altura fija
            SizedBox(
              height: items.length * 40.0 > 200 ? 200 : (items.length * 40.0 == 0 ? 40 : items.length * 40.0), // Altura adaptable o max 200
              child: items.isEmpty
                  ? Center(child: Text('No hay ${title.toLowerCase()}'))
                  : ListView.builder(
                physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll si es pequeño
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(item['icon'] ?? defaultIcon, size: 24, color: Colors.grey[700]),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['name'].toString(),
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item['value'].toString(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// EL WIDGET PRINCIPAL AdminHomeScreen (Dashboard)
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    
    // Watch the pedidos stream provider
    final AsyncValue<List> pedidosAsyncValue = ref.watch(pedidosStreamProvider);



    // Datos de ejemplo para las tarjetas de resumen
    final List<Map<String, dynamic>> summaryData = [
      {'title': 'Ventas de hoy', 'value': '\$1.200', 'icon': Icons.attach_money, 'iconColor': Colors.green},
      {'title': 'Ventas mensuales', 'value': '8.500', 'icon': Icons.payments, 'iconColor': Colors.blue},
      {'title': 'Pedidos', 'value': '5 en curso\n20 completados', 'icon': Icons.receipt_long, 'iconColor': Colors.purple},
      {'title': 'Inventario Bajo', 'value': '5', 'icon': Icons.warning_amber, 'iconColor': kStrongRed, 'valueColor': kStrongRed}, // Usando el rojo fuerte aquí
    ];

    // Datos de ejemplo para Platos más vendidos
    final List<Map<String, dynamic>> topDishes = [
      {'name': 'Pasta', 'value': '120', 'icon': Icons.dinner_dining},
      {'name': 'Hamburguesa', 'value': '90', 'icon': Icons.lunch_dining},
      {'name': 'Ensalada', 'value': '75', 'icon': Icons.rice_bowl},
    ];

    // Datos de ejemplo para Productos más vendidos (Fatos en la imagen)
    final List<Map<String, dynamic>> topProducts = [
      {'name': 'Aceite de Oliva', 'value': '50 L', 'icon': Icons.set_meal},
      {'name': 'Tomate', 'value': '35 Kg', 'icon': Icons.local_florist},
      {'name': 'Harina', 'value': '20 Kg', 'icon': Icons.food_bank},
    ];

    // Datos de ejemplo para Personal activo
    final List<Map<String, dynamic>> activeStaff = [
      {'name': 'Juan', 'value': 'Camarero', 'icon': Icons.person},
      {'name': 'Maria', 'value': 'Cocinera', 'icon': Icons.person},
      {'name': 'Pedro', 'value': 'Gerente', 'icon': Icons.person},
    ];


    return Scaffold(
      backgroundColor: Colors.grey[50], // Un gris muy suave para el fondo del Scaffold
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: kStrongRed, // AppBar con el rojo fuerte
        iconTheme: const IconThemeData(color: Colors.white), // Icono de menú blanco
        elevation: 0, // Sin sombra en el AppBar
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: menuDrawerAdmin(context, authService), // Asegúrate que menuDrawerAdmin tiene un DrawerHeader con color.
      ),
      body: SingleChildScrollView( // Permite desplazamiento si el contenido es demasiado largo
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de tarjetas de resumen
            LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;
                const double cardSpacing = 16.0;
                const double minCardWidth = 160.0;

                int crossAxisCount = (screenWidth / (minCardWidth + cardSpacing)).floor();
                if (crossAxisCount < 1) crossAxisCount = 1;

                final double itemWidth = (screenWidth - (cardSpacing * (crossAxisCount - 1))) / crossAxisCount;

                return Wrap(
                  spacing: cardSpacing,
                  runSpacing: cardSpacing,
                  children: summaryData.map((data) {
                    return SizedBox(
                      width: itemWidth,
                      height: 120, // Altura ajustada
                      child: DashboardSummaryCard(
                        title: data['title'].toString(),
                        value: data['value'].toString(),
                        icon: data['icon'] as IconData,
                        iconColor: data['iconColor'] as Color?,
                        valueColor: data['valueColor'] as Color?,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Sección de Ventas y Platos más vendidos (en una Row)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3, // Ocupa 3 partes del espacio
                  child: SalesChartWidget(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2, // Ocupa 2 partes del espacio
                  child: DashboardListCard(
                    title: 'Pedidos Activos',
                    items: topDishes,
                    defaultIcon: Icons.restaurant_menu,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sección de Productos más vendidos y Personal activo (en otra Row)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: DashboardListCard(
                    title: 'Productos más vendidos',
                    items: topProducts,
                    defaultIcon: Icons.shopping_bag,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DashboardListCard(
                    title: 'Personal activo',
                    items: activeStaff,
                    defaultIcon: Icons.person_pin,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}