import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../storage/hive_client.dart';
import '../storage/hive_product.dart';
import '../storage/hive_sale.dart';
import '../services/sync_service.dart';

class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  final sync = SyncService();

  @override
  Widget build(BuildContext context) {
    final sales = HiveSaleDB.getAll();
    final clients = HiveClientDB.getAll();
    final products = HiveProductDB.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text("Vendas Registradas")),
      body: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (_, i) {
          final s = sales[i];

          final client = clients.firstWhere(
            (c) => c.id == s.clientId,
            orElse: () => Client(id: 0, name: "Cliente ?", companyName: ""),
          );

          final product = products.firstWhere(
            (p) => p.id == s.productId,
            orElse: () => Product(id: 0, name: "Produto ?", price: 0),
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text("${client.name} - ${product.name}"),
              subtitle: Text(
                "Qtd: ${s.quantity}   Total: R\$ ${s.total.toStringAsFixed(2)}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // EDITAR
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editSale(s, i),
                  ),
                  // EXCLUIR
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSale(i),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =======================
  // EXCLUIR VENDA
  // =======================
  Future<void> _deleteSale(int index) async {
    await HiveSaleDB.delete(index);
    await sync.syncSales();
    setState(() {});
  }

  // =======================
  // EDITAR VENDA
  // =======================

  Future<void> _editSale(Sale sale, int index) async {
    final clients = HiveClientDB.getAll();
    final products = HiveProductDB.getAll();

    int? selectedClient = sale.clientId;
    int? selectedProduct = sale.productId;
    int quantity = sale.quantity;
    double price = sale.total / sale.quantity;
    double total = sale.total;

    void calculateTotal() {
      total = price * quantity;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar Venda"),
          content: StatefulBuilder(
            builder: (_, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CLIENTE
                  DropdownButton<int>(
                    value: selectedClient,
                    isExpanded: true,
                    items: clients.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedClient = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // PRODUTO
                  DropdownButton<int>(
                    value: selectedProduct,
                    isExpanded: true,
                    items: products.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text("${p.name} (R\$ ${p.price})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedProduct = value;
                        price = products.firstWhere((p) => p.id == value).price;
                        calculateTotal();
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // QUANTIDADE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setDialogState(() {
                              quantity--;
                              calculateTotal();
                            });
                          }
                        },
                      ),
                      Text(quantity.toString(),
                          style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setDialogState(() {
                            quantity++;
                            calculateTotal();
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // TOTAL
                  Text(
                    "Total: R\$ ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedClient == null || selectedProduct == null) return;

                sale.clientId = selectedClient!;
                sale.productId = selectedProduct!;
                sale.quantity = quantity;
                sale.total = total;
                sale.synced = false;
                sale.save();

                sync.syncSales();
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }
}
