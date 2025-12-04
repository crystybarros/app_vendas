import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';
import '../models/sale.dart';

class ClientService {
  // Emulador Android usa 10.0.2.2
  static const String baseUrl = "http://10.0.2.2:8080/clients";

  Future<bool> sendToServer(Client c) async {
    try {
      if (c.id == null) {
        // Criar novo
        await http.post(
          Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(c.toJson()),
        );
      } else {
        // Atualizar
        await http.put(
          Uri.parse("$baseUrl/${c.id}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(c.toJson()),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteServer(int id) async {
    try {
      await http.delete(Uri.parse("$baseUrl/$id"));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await http.delete(Uri.parse("http://10.0.2.2:8080/products/$id"));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendSale(Sale s) async {
    try {
      await http.post(
        Uri.parse("http://10.0.2.2:8080/sales"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(s.toJson()),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
