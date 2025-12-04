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

    // ====================== ROTAS PRODUTOS =========================

// GET produtos
    router.get('/products', (Request req) {
      return Response.ok(jsonEncode(db.getProducts()),
          headers: {'Content-Type': 'application/json'});
    });

// POST adicionar produto
    router.post('/products', (Request req) async {
      final body = jsonDecode(await req.readAsString());
      db.insertProduct(body['name'], body['price'].toDouble());
      return Response(201, body: "Produto cadastrado");
    });

// PUT atualizar produto
    router.put('/products/<id|[0-9]+>', (Request req, String id) async {
      final body = jsonDecode(await req.readAsString());
      db.updateProduct(int.parse(id), body['name'], body['price'].toDouble());
      return Response.ok("Produto atualizado");
    });

// DELETE remover produto
    router.delete('/products/<id|[0-9]+>', (Request req, String id) {
      db.deleteProduct(int.parse(id));
      return Response.ok("Produto removido");
    });

// ====================== ROTAS DE VENDAS =========================

// POST venda
    router.post('/sales', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      // TODO: Futuro -> salvar no banco
      // por enquanto apenas aceita o POST

      return Response(201, body: "Venda registrada");
    });

    return router;
  }
}
