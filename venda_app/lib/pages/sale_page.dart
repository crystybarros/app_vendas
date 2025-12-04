import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../storage/hive_client.dart';
import '../storage/hive_product.dart';
import '../storage/hive_sale.dart';
import '../services/sync_service.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  int? selectedClient;
  int? selectedProduct;
  int quantity = 1;
  double price = 0.0;
  double total = 0.0;

  final sync = SyncService();

  void calculateTotal() {
    setState(() {
      total = price * quantity;
    });
  }

  Future saveSale() async {
    if (selectedClient == null || selectedProduct == null) return;

    await HiveSaleDB.add(Sale(
      clientId: selectedClient!,
      productId: selectedProduct!,
      quantity: quantity,
      total: total,
      synced: false,
    ));

    sync.syncSales();

    setState(() {
      selectedClient = null;
      selectedProduct = null;
      quantity = 1;
      price = 0;
      total = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Venda salva!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = HiveClientDB.getAll();
    final products = HiveProductDB.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Venda")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CLIENTE
            const Text("Cliente"),
            DropdownButton<int>(
              value: selectedClient,
              hint: const Text("Selecione"),
              isExpanded: true,
              items: clients.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedClient = value);
              },
            ),

            const SizedBox(height: 20),

            // PRODUTO
            const Text("Produto"),
            DropdownButton<int>(
              value: selectedProduct,
              hint: const Text("Selecione"),
              isExpanded: true,
              items: products.map((p) {
                return DropdownMenuItem(
                  value: p.id,
                  child: Text("${p.name} (R\$ ${p.price})"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProduct = value;
                  price = products.firstWhere((p) => p.id == value).price;
                  calculateTotal();
                });
              },
            ),

            const SizedBox(height: 20),

            // QUANTIDADE
            const Text("Quantidade"),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (quantity > 1) {
                      quantity--;
                      calculateTotal();
                    }
                  },
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    quantity++;
                    calculateTotal();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // TOTAL
            Text(
              "Total: R\$ ${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            // BOTÃO SALVAR
            ElevatedButton(
              onPressed: saveSale,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Salvar Venda"),
            )
          ],
        ),
      ),
    );
  }
}
