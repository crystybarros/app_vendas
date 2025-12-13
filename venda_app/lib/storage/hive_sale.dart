import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';

class HiveSaleDB {
  static const boxName = "sales";

  /// Inicializa o Hive e abre a box de vendas
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(SaleAdapter().typeId)) {
      Hive.registerAdapter(SaleAdapter());
    }
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Sale>(boxName);
    }
  }

  /// Retorna a box de vendas
  static Box<Sale> box() => Hive.box<Sale>(boxName);

  /// Retorna todas as vendas
  static List<Sale> getAll() => box().values.toList();

  /// Adiciona venda e retorna a chave gerada automaticamente
  static Future<int> add(Sale s) async {
    final key = await box().add(s); // chave auto-incremental do Hive
    return key;
  }

  /// Deleta pelo ID real (key do Hive)
  static Future<void> delete(dynamic key) => box().delete(key);
}
