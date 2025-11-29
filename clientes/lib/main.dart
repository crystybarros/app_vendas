import 'package:flutter/material.dart';
import 'storage/hive_client.dart';
import 'pages/client_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveClientDB.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clientes Offline',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const ClientPage(),
    );
  }
}
