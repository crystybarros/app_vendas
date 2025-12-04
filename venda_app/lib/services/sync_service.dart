import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/client.dart';
import '../storage/hive_client.dart';
import 'client_service.dart';
import '../storage/hive_product.dart';
import '../models/product.dart';
import '../storage/hive_sale.dart';
import '../models/sale.dart';

class SyncService {
  final ClientService clientApi = ClientService();

  // Sincroniza clientes pendentes (synced == false)
  Future<void> syncPending() async {
    final all = HiveClientDB.getAll();

    for (final c in all) {
      if (!c.synced) {
        final ok = await clientApi.sendToServer(c);
        if (ok) {
          final index = all.indexOf(c);
          await HiveClientDB.updateSyncStatus(index, true);
        }
      }
    }
  }

  // Monitora conexão e dispara sync quando voltar a internet
  void startAutoSync() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        syncPending(); // clientes e produtos
        syncSales(); // vendas
      }
    });
  }

  // Excluir cliente local + no servidor (se tiver id)
  Future<void> deleteWithSync(int index) async {
    final list = HiveClientDB.getAll();
    if (index < 0 || index >= list.length) return;

    final client = list[index];

    // Se já tem id no servidor, tenta excluir lá
    if (client.id != null) {
      final ok = await clientApi.deleteServer(client.id!);
      if (ok) {
        await client.delete();
      }
    } else {
      // Só local
      await client.delete();
    }
  }

  Future deleteProductWithSync(int index) async {
    final list = HiveProductDB.getAll();
    final p = list[index];

    if (p.id != null) {
      final ok = await clientApi.deleteProduct(p.id!);
      if (ok) p.delete();
    } else {
      p.delete();
    }
  }

  Future syncSales() async {
    final all = HiveSaleDB.getAll();

    for (final s in all) {
      if (!s.synced) {
        final ok = await clientApi.sendSale(s);
        if (ok) {
          final index = all.indexOf(s);
          s.synced = true;
          s.save();
        }
      }
    }
  }
}
