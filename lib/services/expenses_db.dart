import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpensesDb {
  ExpensesDb._();
  static final ExpensesDb instance = ExpensesDb._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'expenses.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          note TEXT NOT NULL,
          date TEXT NOT NULL
        )
      '''),
    );
  }

  Future<int> insert(Expense expense) async {
    final db = await database;
    final map = expense.toMap();
    map.remove('id');
    return db.insert('expenses', map);
  }

  Future<List<Expense>> getAll() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map((r) => Expense.fromMap(r)).toList();
  }

  Future<int> update(Expense expense) async {
    final db = await database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByMonth(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total FROM expenses
      WHERE date >= ? AND date < ?
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    final sum = result.first['total'] as double?;
    return sum ?? 0.0;
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('expenses');
  }
}
