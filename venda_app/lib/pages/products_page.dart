import 'package:flutter/material.dart';
import '../models/product.dart';
import '../storage/hive_product.dart';
import '../services/sync_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final sync = SyncService();

  Future addProduct() async {
    await HiveProductDB.add(Product(
      name: nameCtrl.text,
      price: double.parse(priceCtrl.text),
      synced: false,
    ));

    nameCtrl.clear();
    priceCtrl.clear();
    setState(() {});
    sync.syncPending();
  }

  Future edit(Product p, int index) async {
    nameCtrl.text = p.name;
    priceCtrl.text = p.price.toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Produto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nome")),
            TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Preço")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              p.name = nameCtrl.text;
              p.price = double.parse(priceCtrl.text);
              p.synced = false;
              p.save();
              setState(() {});
              sync.syncPending();
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future delete(int index) async {
    await sync.deleteProductWithSync(index); // vamos adicionar agora no sync
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = HiveProductDB.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text("Produtos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nome")),
                TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: "Preço")),
                ElevatedButton(
                    onPressed: addProduct, child: const Text("Cadastrar")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final p = list[i];

                return ListTile(
                  leading: Text(p.id?.toString() ?? "-"),
                  title: Text(p.name),
                  subtitle: Text("R\$ ${p.price.toStringAsFixed(2)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => edit(p, i)),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => delete(i)),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
