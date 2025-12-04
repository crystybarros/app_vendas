import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class HiveProductDB {
  static const boxName = "products";

  static Future init() async {
    Hive.registerAdapter(ProductAdapter());
    await Hive.openBox<Product>(boxName);
  }

  static Box<Product> box() => Hive.box<Product>(boxName);

  static List<Product> getAll() => box().values.toList();

  static Future add(Product p) => box().add(p);
}
