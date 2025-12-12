import 'package:flutter/material.dart';
import 'storage/hive_client.dart';
import 'storage/hive_product.dart';
import 'storage/hive_sale.dart';
import 'pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveClientDB.init();
  await HiveProductDB.init();
  await HiveSaleDB.init();

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
      home: const WelcomePage(),
    );
  }
}
