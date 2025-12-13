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
  dynamic selectedClientKey;
  dynamic selectedProductKey;
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
    if (selectedClientKey == null || selectedProductKey == null) return;

    final productBox = HiveProductDB.box();
    final product = productBox.get(selectedProductKey)!;

    await HiveSaleDB.add(Sale(
      clientId: selectedClientKey, // chave real do Hive
      productId: selectedProductKey, // chave real do Hive
      quantity: quantity,
      total: total,
      synced: false,
    ));

    await sync.syncSales();

    // Resetar campos
    setState(() {
      selectedClientKey = null;
      selectedProductKey = null;
      quantity = 1;
      price = 0;
      total = 0;
    });

    // Mostrar mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Venda salva!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientBox = HiveClientDB.box();
    final productBox = HiveProductDB.box();

    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Venda")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CLIENTE
            const Text("Cliente"),
            DropdownButton<dynamic>(
              value: selectedClientKey,
              hint: const Text("Selecione"),
              isExpanded: true,
              items: clientBox.keys.map((key) {
                final c = clientBox.get(key)!;
                return DropdownMenuItem(
                  value: key,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedClientKey = value);
              },
            ),

            const SizedBox(height: 20),

            // PRODUTO
            const Text("Produto"),
            DropdownButton<dynamic>(
              value: selectedProductKey,
              hint: const Text("Selecione"),
              isExpanded: true,
              items: productBox.keys.map((key) {
                final p = productBox.get(key)!;
                return DropdownMenuItem(
                  value: key,
                  child: Text("${p.name} (R\$ ${p.price})"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProductKey = value;
                  price = productBox.get(value)!.price;
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
                      setState(() {
                        quantity--;
                        calculateTotal();
                      });
                    }
                  },
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      quantity++;
                      calculateTotal();
                    });
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
