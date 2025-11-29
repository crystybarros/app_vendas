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
  }

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
}
