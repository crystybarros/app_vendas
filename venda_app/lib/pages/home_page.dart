import 'package:flutter/material.dart';
import 'client_page.dart';
import 'products_page.dart';
import 'sale_page.dart';
import 'sale_list_page.dart';
import 'welcome_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // COR DE FUNDO ALTERADA
      backgroundColor: const Color(0xFFE3F2FD), // azul claro suave

      appBar: AppBar(
        title: const Text("Menu Principal"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
              );
            },
            tooltip: "Sair",
          )
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BOTÃO CLIENTES
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClientPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Cadastro de Clientes"),
              ),

              const SizedBox(height: 16),

              // BOTÃO PRODUTOS
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Cadastro de Produtos"),
              ),

              const SizedBox(height: 16),

              // BOTÃO REGISTRAR VENDA
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Registrar Venda"),
              ),

              const SizedBox(height: 16),

              // BOTÃO LISTAR VENDAS
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SaleListPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Listar Vendas"),
              ),

              const SizedBox(height: 40),

              // BOTÃO SAIR - EXTRA
              OutlinedButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text(
                  "Sair",
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
