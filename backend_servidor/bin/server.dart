import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:sales_force_api/database_service.dart';
import 'package:sales_force_api/api_service.dart';

void main(List<String> args) async {
  final dbService = DatabaseService();
  await dbService.initDatabase();

  final api = ApiService(dbService);

  // Middleware de log e CORS
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(api.router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Servidor rodando em http://${server.address.host}:${server.port}');
}
