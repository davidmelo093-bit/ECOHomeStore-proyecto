import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String token;
  final String username;
  final VoidCallback onLogout;

  const ProductsScreen({
    super.key,
    required this.token,
    required this.username,
    required this.onLogout,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  String _searchQuery = '';
  bool _loading = true;
  String? _error;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = AuthService.extractRole(widget.token) == 'admin';
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      _products = await ApiService.getProducts();
      setState(() {});
    } on Exception catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Productos creados por el usuario actual, calculado de la lista ya cargada.
  int get _userProductCount => _products
      .where((p) => p['created_by_username']?.toString() == widget.username)
      .length;

  List<dynamic> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final q = _searchQuery.toLowerCase();
    return _products.where((p) {
      final name = p['name']?.toString().toLowerCase() ?? '';
      return name.contains(q);
    }).toList();
  }

  Future<void> _confirmDelete(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Seguro de que deseas eliminar "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteProduct(id, widget.token);
      setState(() {
        _products.removeWhere((p) => p['id'] == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> product) async {
    final nameCtrl = TextEditingController(text: product['name']?.toString());
    final priceCtrl = TextEditingController(text: product['price']?.toString());
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Producto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Campo requerido';
                  final p = double.tryParse(val);
                  if (p == null || p <= 0) return 'Ingrese un precio válido (> 0)';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final id = product['id'] as int;
                final name = nameCtrl.text.trim();
                final price = double.parse(priceCtrl.text);

                try {
                  final result = await ApiService.updateProduct(id, name, price, widget.token);
                  final idx = _products.indexWhere((p) => p['id'] == id);
                  if (idx != -1) {
                    setState(() => _products[idx] = result);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado con éxito')),
      );
    }
  }

  Future<void> _showCreateDialog() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nuevo Producto',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio (\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Campo requerido';
                      final p = double.tryParse(val);
                      if (p == null || p <= 0) return 'Ingrese un precio válido (> 0)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(ctx).colorScheme.primary,
                      foregroundColor: Theme.of(ctx).colorScheme.onPrimary,
                    ),
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final name = nameCtrl.text.trim();
                        final price = double.parse(priceCtrl.text);
                        try {
                          final newProduct = await ApiService.createProduct(name, price, widget.token);
                          setState(() => _products.insert(0, newProduct));
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Crear Producto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username} ($_userProductCount)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _fetchAll,
            tooltip: 'Recargar',
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchAll, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    Expanded(
                      child: _filteredProducts.isEmpty
                          ? const Center(child: Text('No hay resultados'))
                          : ListView.builder(
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final p = _filteredProducts[index];
                                final id = p['id'] as int;
                                final name = p['name']?.toString() ?? '—';
                                final creator = p['created_by_username']?.toString();
                                return ListTile(
                                  leading: CircleAvatar(child: Text('${index + 1}')),
                                  title: Text(name),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        '\$${p['price']?.toString() ?? '0'}',
                                        style: const TextStyle(color: Colors.green),
                                      ),
                                      if (creator != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '· $creator',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: _isAdmin
                                      ? PopupMenuButton<String>(
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              _showEditDialog(p);
                                            } else if (val == 'delete') {
                                              _confirmDelete(id, name);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, color: Colors.blue, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Editar'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Eliminar'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(product: p),
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
}