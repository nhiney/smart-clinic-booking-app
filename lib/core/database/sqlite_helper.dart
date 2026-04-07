import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteHelper {
  static final SQLiteHelper instance = SQLiteHelper._init();
  static Database? _database;

  SQLiteHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medical_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCacheTables(db);
    }
    if (oldVersion < 3) {
      await db.execute('''
CREATE TABLE hospitals_cache (
  id TEXT PRIMARY KEY,
  data TEXT NOT NULL
)
''');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const jsonType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE encounters (
  id $idType,
  patientId $textType,
  lastUpdated $textType,
  data $jsonType
)
''');

    await db.execute('''
CREATE TABLE observations (
  id $idType,
  patientId $textType,
  encounterId $textType,
  data $jsonType
)
''');

    await _createCacheTables(db);
    // Include the version 3 table on initial creation as well
    await db.execute('''
CREATE TABLE hospitals_cache (
  id $idType,
  data $jsonType
)
''');

    await _createPaymentCacheTables(db);
  }

  Future _createPaymentCacheTables(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const jsonType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE transactions_cache (
  id $idType,
  userId TEXT NOT NULL,
  data $jsonType
)
''');

    await db.execute('''
CREATE TABLE invoices_cache (
  id $idType,
  userId TEXT NOT NULL,
  data $jsonType
)
''');

    await db.execute('''
CREATE TABLE medical_records_cache (
  id $idType,
  userId TEXT NOT NULL,
  data $jsonType
)
''');
  }

  Future _createCacheTables(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const jsonType = 'TEXT NOT NULL';
    const categoryType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE faq_cache (
  id $idType,
  category $categoryType,
  data $jsonType
)
''');

    await db.execute('''
CREATE TABLE news_cache (
  id $idType,
  data $jsonType
)
''');

    await db.execute('''
CREATE TABLE health_library_cache (
  id $idType,
  category $categoryType,
  data $jsonType
)
''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
