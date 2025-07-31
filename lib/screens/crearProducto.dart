// lib/screens/crear_producto_page.dart
import 'package:firebase_auth_app/models/categoriaProducto_model.dart';
import 'package:firebase_auth_app/providers/categoriasProductos_provider.dart';
import 'package:firebase_auth_app/services/cateogiras_productos_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth_app/services/productos_service.dart';

class CrearProductoPage extends ConsumerStatefulWidget {
  const CrearProductoPage({super.key});

  @override
  ConsumerState<CrearProductoPage> createState() => _CrearProductoPageState();
}

class _CrearProductoPageState extends ConsumerState<CrearProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
  final TextEditingController _nuevaCategoriaTextController = TextEditingController(); // Para el diálogo

  String? _selectedCategoria; // Para el valor del Dropdown

  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _imagenController.dispose();
    _nuevaCategoriaTextController.dispose();
    super.dispose();
  }

  Future<void> _crearProducto() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String nombre = _nombreController.text.trim();
      final double precio = double.tryParse(_precioController.text.trim()) ?? 0.0;
      final String categoria = _selectedCategoria ?? ''; // Obtiene del dropdown
      final String imagen = _imagenController.text.trim().isEmpty
          ? 'https://via.placeholder.com/150' // URL de imagen por defecto
          : _imagenController.text.trim();

      // Validación final para la categoría (en caso de que el validador del dropdown falle o sea bypassado)
      if (categoria.isEmpty) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Por favor, selecciona una categoría.')),
           );
           setState(() => _isLoading = false);
         }
         return;
      }

      final Map<String, dynamic> nuevoProductoData = {
        'nombre': nombre,
        'precio': precio,
        'categoria': categoria,
        'imagen': imagen,
      };

      try {
        final productosService = ref.read(productosServiceProvider);
        await productosService.addProducto(nuevoProductoData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto creado exitosamente!')),
          );
          _nombreController.clear();
          _precioController.clear();
          _imagenController.clear();
          setState(() {
            _selectedCategoria = null; // Reiniciar selección
          });
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear el producto: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _mostrarDialogoNuevaCategoria() async {
    _nuevaCategoriaTextController.clear(); // Limpiar antes de mostrar
    final newCategoryName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nueva Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _nuevaCategoriaTextController,
            decoration: InputDecoration(
              hintText: 'Nombre de la nueva categoría',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final categoryName = _nuevaCategoriaTextController.text.trim();
                if (categoryName.isNotEmpty) {
                  final categoriasService = ref.read(categoriasServiceProvider);
                  try {
                    await categoriasService.addCategoria({'nombre': categoryName});
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Categoría "$categoryName" creada!')),
                       );
                    }
                    Navigator.of(context).pop(categoryName);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear categoría: $e')),
                      );
                    }
                    Navigator.of(context).pop();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El nombre no puede estar vacío.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (newCategoryName != null && mounted) {
      setState(() {
        _selectedCategoria = newCategoryName;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CategoriaProducto>> categoriasAsyncValue = ref.watch(categoriasStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Producto', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white), // Color de la flecha de atrás
      ),
      body: categoriasAsyncValue.when(
        data: (categoriasObj) {
          final List<String> categoriasNombres = categoriasObj.map((cat) => cat.nombre).toList();
          categoriasNombres.sort(); // Ordenar alfabéticamente

          if (_selectedCategoria != null && !categoriasNombres.contains(_selectedCategoria)) {
             _selectedCategoria = null;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0), // Mayor padding general
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Producto',
                      hintText: 'Ej: Hamburguesa Clásica',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: const Icon(Icons.shopping_basket_outlined),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el nombre del producto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20), // Mayor espacio
                  TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      hintText: 'Ej: 9.99',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: const Icon(Icons.euro),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el precio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor, introduce un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Contenedor para la sección de categoría
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.zero, // Elimina el margen del Card
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categoría del Producto',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategoria,
                                  decoration: InputDecoration(
                                    labelText: 'Selecciona una categoría',
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    prefixIcon: const Icon(Icons.category_outlined),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  ),
                                  items: categoriasNombres.isEmpty
                                      ? [
                                          const DropdownMenuItem<String>(
                                            value: null, // Asegura que el valor nulo es una opción si no hay categorías
                                            child: Text('No hay categorías disponibles'),
                                          )
                                        ]
                                      : categoriasNombres.map((String categoriaNombre) {
                                          return DropdownMenuItem<String>(
                                            value: categoriaNombre,
                                            child: Text(categoriaNombre),
                                          );
                                        }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedCategoria = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, selecciona una categoría';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Botón de añadir categoría con estilo más integrado
                              ElevatedButton(
                                onPressed: _mostrarDialogoNuevaCategoria,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent, // Color de acento
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                ),
                                child: const Icon(Icons.add_circle_outline, size: 24),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _imagenController,
                    decoration: InputDecoration(
                      labelText: 'URL de la Imagen (opcional)',
                      hintText: 'https://ejemplo.com/imagen.jpg',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: const Icon(Icons.image_outlined),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 30), // Más espacio antes del botón final
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _crearProducto,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add_box),
                      label: Text(
                        _isLoading ? 'Creando...' : 'Crear Producto',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes redondeados
                        ),
                        elevation: 5, // Sombra
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error al cargar categorías: $error')),
      ),
    );
  }
}