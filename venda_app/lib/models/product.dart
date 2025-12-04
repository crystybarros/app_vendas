import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 2)
class Product extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  bool synced;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
      };

  factory Product.fromJson(Map json) => Product(
        id: json["id"],
        name: json["name"],
        price: (json["price"] as num).toDouble(),
        synced: true,
      );
}
