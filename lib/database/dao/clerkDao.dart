import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webcam_app/database/model/clerk.dart';

class ClerkDao {
  static final ClerkDao instance = ClerkDao._init();

  static Database? _database;

  ClerkDao._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('clerks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE $tableClerk ( 
  ${ClerkFields.id} $idType, 
  ${ClerkFields.account} $textType,
  ${ClerkFields.password} $textType
  )
''');
  }

  Future<Clerk> insert(Clerk clerk) async {
    final db = await instance.database;

    final id = await db.insert(tableClerk, clerk.toJson());
    return clerk.copy(id: id);
  }

  Future<void> delete() async {
    final db = await instance.database;

    await db.delete(
      tableClerk,
    );
  }

  Future readClerkById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableClerk,
      columns: ClerkFields.values,
      where: '${ClerkFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Clerk.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Clerk>> readAllNotes() async {
    final db = await instance.database;

    final orderBy = '${ClerkFields.id} ASC';

    final result = await db.query(tableClerk, orderBy: orderBy);

    return result.map((json) => Clerk.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
