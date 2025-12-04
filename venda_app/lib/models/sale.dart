import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 3)
class Sale extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int clientId;

  @HiveField(2)
  int productId;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double total;

  @HiveField(5)
  bool synced;

  Sale({
    this.id,
    required this.clientId,
    required this.productId,
    required this.quantity,
    required this.total,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "clientId": clientId,
        "productId": productId,
        "quantity": quantity,
        "total": total,
      };

  factory Sale.fromJson(Map json) => Sale(
        id: json["id"],
        clientId: json["clientId"],
        productId: json["productId"],
        quantity: json["quantity"],
        total: (json["total"] as num).toDouble(),
        synced: true,
      );
}
