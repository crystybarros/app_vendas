import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String companyName;

  @HiveField(3)
  bool synced;

  Client({
    this.id,
    required this.name,
    required this.companyName,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "companyName": companyName,
      };

  factory Client.fromJson(Map json) => Client(
        id: json["id"],
        name: json["name"],
        companyName: json["companyName"],
        synced: true,
      );
}
