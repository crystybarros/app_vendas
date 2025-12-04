import 'package:flutter/material.dart';
import 'storage/hive_client.dart';
import 'storage/hive_product.dart';
import 'pages/home_page.dart'; // import da tela inicial

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await HiveClientDB.init();
  await HiveProductDB.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Vendas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
