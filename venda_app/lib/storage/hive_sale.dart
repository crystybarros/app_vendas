import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';

class HiveSaleDB {
  static const boxName = "sales";

  static Future init() async {
    Hive.registerAdapter(SaleAdapter());
    await Hive.openBox<Sale>(boxName);
  }

  static Box<Sale> box() => Hive.box<Sale>(boxName);

  static List<Sale> getAll() => box().values.toList();

  static Future add(Sale s) => box().add(s);

  static Future delete(int index) => box().deleteAt(index);
}
