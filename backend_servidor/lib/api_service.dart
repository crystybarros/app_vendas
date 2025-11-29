import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database_service.dart';

class ApiService {
  final DatabaseService db;

  ApiService(this.db);

  Router get router {
    final router = Router();

    router.get('/clients', (Request request) {
      final clients = db.getClients();
      return Response.ok(jsonEncode(clients),
          headers: {'Content-Type': 'application/json'});
    });

    router.post('/clients', (Request request) async {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final name = data["name"] ?? "";
      final companyName = data["companyName"] ?? "";

      if (name.isEmpty || companyName.isEmpty) {
        return Response(400, body: "Dados incompletos");
      }

      db.insertClient(name, companyName);
      return Response(201, body: "Cliente criado");
    });

    router.delete('/clients/<id|[0-9]+>', (Request request, String id) {
      db.deleteClient(int.parse(id));
      return Response.ok("Cliente removido");
    });

    // PUT - Atualizar cliente
    router.put('/clients/<id|[0-9]+>', (Request request, String id) async {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      db.updateClient(
        int.parse(id),
        data["name"],
        data["companyName"],
      );

      return Response.ok("Cliente atualizado");
    });

// DELETE - remover cliente
    router.delete('/clients/<id|[0-9]+>', (Request request, String id) {
      db.deleteClient(int.parse(id));
      return Response.ok("Cliente removido");
    });

    return router;
  }
}
