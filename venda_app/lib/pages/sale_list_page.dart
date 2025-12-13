import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final SyncService sync = SyncService();

  @override
  Widget build(BuildContext context) {
    final saleBox = HiveSaleDB.box();
    final clientBox = HiveClientDB.box();
    final productBox = HiveProductDB.box();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendas Registradas"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // LISTA DE VENDAS (reage a mudanças em vendas, clientes e produtos)
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: saleBox.listenable(),
              builder: (_, Box<Sale> sales, __) {
                if (sales.isEmpty) {
                  return const Center(child: Text("Nenhuma venda registrada"));
                }

                // Recalcula total sempre que vendas mudarem
                final totalGeral =
                    sales.values.fold<double>(0, (sum, s) => sum + (s.total));

                // Keys reais das vendas, garantindo correspondência
                final saleKeys = sales.keys.toList();

                return ValueListenableBuilder(
                  // Escuta clientes também
                  valueListenable: clientBox.listenable(),
                  builder: (_, Box<Client> clientsBox, __) {
                    final clientsMap = clientsBox.toMap();

                    return ValueListenableBuilder(
                      // Escuta produtos também
                      valueListenable: productBox.listenable(),
                      builder: (_, Box<Product> productsBox, __) {
                        final productsMap = productsBox.toMap();

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: saleKeys.length,
                                itemBuilder: (_, index) {
                                  final saleKey = saleKeys[index];
                                  final Sale? sale = sales.get(saleKey);
                                  if (sale == null) {
                                    return const SizedBox.shrink();
                                  }

                                  // Usa as chaves reais gravadas em sale.clientId e sale.productId
                                  final Client? client =
                                      clientsMap[sale.clientId];
                                  final Product? product =
                                      productsMap[sale.productId];

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        "${client?.name ?? 'Cliente ?'} - ${product?.name ?? 'Produto ?'}",
                                      ),
                                      subtitle: Text(
                                        "Qtd: ${sale.quantity}   Total: R\$ ${sale.total.toStringAsFixed(2)}",
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () =>
                                                _editSale(context, saleKey),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _deleteSale(context, saleKey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                            // TOTAL GERAL sempre consistente e atualizado
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Geral:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "R\$ ${totalGeral.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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

  // =======================
  // EXCLUIR VENDA
  // =======================
  Future<void> _deleteSale(BuildContext context, dynamic saleKey) async {
    await HiveSaleDB.delete(saleKey);
    await sync.syncSales();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Venda excluída")),
    );
  }

  // =======================
  // EDITAR VENDA
  // =======================
  Future<void> _editSale(BuildContext context, dynamic saleKey) async {
    final saleBox = HiveSaleDB.box();
    final clientBox = HiveClientDB.box();
    final productBox = HiveProductDB.box();

    final Sale sale = saleBox.get(saleKey)!;

    // Usa mapas key->objeto para consistência
    final clientEntries = clientBox.toMap();
    final productEntries = productBox.toMap();

    dynamic selectedClientKey = sale.clientId;
    dynamic selectedProductKey = sale.productId;

    int quantity = sale.quantity;
    double price = productEntries[selectedProductKey]?.price ?? 0;
    double total = quantity * price;

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
                  // CLIENTE por chave real
                  DropdownButton<dynamic>(
                    value: selectedClientKey,
                    isExpanded: true,
                    items: clientEntries.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedClientKey = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // PRODUTO por chave real
                  DropdownButton<dynamic>(
                    value: selectedProductKey,
                    isExpanded: true,
                    items: productEntries.entries.map((e) {
                      final p = e.value;
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text("${p.name} (R\$ ${p.price})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedProductKey = value;
                        price = productEntries[value]?.price ?? 0;
                        total = quantity * price;
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
                              total = quantity * price;
                            });
                          }
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setDialogState(() {
                            quantity++;
                            total = quantity * price;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Total: R\$ ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                sale.clientId = selectedClientKey;
                sale.productId = selectedProductKey;
                sale.quantity = quantity;
                sale.total = total;
                sale.synced = false;

                await sale.save();
                await sync.syncSales();

                if (!mounted) return;

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Venda atualizada")),
                );
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }
}
