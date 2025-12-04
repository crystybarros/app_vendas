import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  late Database db;

  Future<void> initDatabase() async {
    final file = File('sales.db');
    db = sqlite3.open(file.path);

    db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        companyName TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL
      );
    ''');
  }

  // ====================== CLIENTES =========================

  List<Map<String, Object?>> getClients() {
    final result = db.select('SELECT id, name, companyName FROM clients');
    return result
        .map((row) => {
              'id': row['id'],
              'name': row['name'],
              'companyName': row['companyName'],
            })
        .toList();
  }

  void insertClient(String name, String companyName) {
    db.execute(
      'INSERT INTO clients (name, companyName) VALUES (?, ?)',
      [name, companyName],
    );
  }

  void deleteClient(int id) {
    db.execute('DELETE FROM clients WHERE id = ?', [id]);
  }

  void updateClient(int id, String name, String companyName) {
    db.execute(
      'UPDATE clients SET name = ?, companyName = ? WHERE id = ?',
      [name, companyName, id],
    );
  }

  // ====================== PRODUTOS =========================

  List<Map<String, Object?>> getProducts() {
    final result = db.select('SELECT id, name, price FROM products');
    return result
        .map((row) => {
              'id': row['id'],
              'name': row['name'],
              'price': row['price'],
            })
        .toList();
  }

  void insertProduct(String name, double price) {
    db.execute(
        'INSERT INTO products (name, price) VALUES (?, ?)', [name, price]);
  }

  void updateProduct(int id, String name, double price) {
    db.execute('UPDATE products SET name = ?, price = ? WHERE id = ?',
        [name, price, id]);
  }

  void deleteProduct(int id) {
    db.execute('DELETE FROM products WHERE id = ?', [id]);
  }
}
