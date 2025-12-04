import 'package:flutter/material.dart';
import '../models/client.dart';
import '../storage/hive_client.dart';
import '../services/sync_service.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController companyCtrl = TextEditingController();
  final sync = SyncService();

  @override
  void initState() {
    super.initState();
    sync.startAutoSync();
  }

  // ===========================
  // ADICIONAR CLIENTE
  // ===========================
  Future<void> addClient() async {
    if (nameCtrl.text.isEmpty || companyCtrl.text.isEmpty) return;

    await HiveClientDB.add(Client(
      name: nameCtrl.text,
      companyName: companyCtrl.text,
      synced: false,
    ));

    setState(() {});
    sync.syncPending();

    nameCtrl.clear();
    companyCtrl.clear();
  }

  // ===========================
  // EDITAR CLIENTE (abre modal)
  // ===========================
  Future<void> editClient(Client client, int index) async {
    nameCtrl.text = client.name;
    companyCtrl.text = client.companyName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Cliente"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: companyCtrl,
              decoration: const InputDecoration(labelText: "Empresa"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              nameCtrl.clear();
              companyCtrl.clear();
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              client.name = nameCtrl.text;
              client.companyName = companyCtrl.text;
              client.synced = false;
              client.save();

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

  // ===========================
  // EXCLUIR CLIENTE
  // ===========================
  Future<void> deleteClient(int index) async {
    await sync.deleteWithSync(index);
    setState(() {});
  }

  // ===========================
  // UI PRINCIPAL
  // ===========================
  @override
  Widget build(BuildContext context) {
    final list = HiveClientDB.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text("Clientes Offline-First")),
      body: Column(
        children: [
          // FORMULÁRIO -----------------------------------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: "Nome do Cliente"),
                ),
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(labelText: "Empresa"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: addClient,
                  child: const Text("Cadastrar"),
                ),
              ],
            ),
          ),

          const Divider(),

          // LISTA ----------------------------------------------
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final c = list[i];
                return ListTile(
                  leading: Text(
                    c.id?.toString() ?? "-",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text(c.name),
                  subtitle: Text("Empresa: ${c.companyName}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editClient(c, i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteClient(i),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
