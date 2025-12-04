import 'package:hive_flutter/hive_flutter.dart';
import '../models/client.dart';

class HiveClientDB {
  static const boxName = "clients";

  static Future init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ClientAdapter());
    await Hive.openBox<Client>(boxName);
  }

  static Box<Client> box() => Hive.box<Client>(boxName);

  static List<Client> getAll() => box().values.toList();

  static Future add(Client client) => box().add(client);

  static Future updateSyncStatus(int index, bool synced) async {
    var c = box().getAt(index);
    if (c != null) {
      c.synced = synced;
      c.save();
    }
  }
}
