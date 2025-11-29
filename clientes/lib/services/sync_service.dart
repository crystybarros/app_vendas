import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/client.dart';
import '../storage/hive_client.dart';
import 'client_service.dart';

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
        syncPending();
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
}
