import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webcam_app/database/model/user.dart';

class UserDao {
  static final UserDao instance = UserDao._init();

  static Database? _database;

  UserDao._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'TEXT NOT NULL PRIMARY KEY ';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE $tableUser ( 
  ${UserFields.id} $idType, 
  ${UserFields.phone} $textType
  )
''');
  }

  Future<User> create(User user) async {
    final db = await instance.database;

    final id = await db.insert(tableUser, user.toJson());
    return user.copy(id: id.toString());
  }

  // Future readUserById(String id) async {
  //   final db = await instance.database;

  //   final maps = await db.query(
  //     tableUser,
  //     columns: UserFields.values,
  //     where: '${UserFields.id} = ?',
  //     whereArgs: [id],
  //   );

  //   if (maps.isNotEmpty) {
  //     return User.fromJson(maps.first);
  //   } else {
  //     throw Exception('ID $id not found');
  //   }
  // }

  // Future<List<User>> readAllNotes() async {
  //   final db = await instance.database;

  //   final orderBy = '${UserFields.id} ASC';
  //   // final result =
  //   //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

  //   final result = await db.query(tableUser, orderBy: orderBy);

  //   return result.map((json) => User.fromJson(json)).toList();
  // }

  // Future readUserByPhone(String phone) async {
  //   final db = await instance.database;

  //   final maps = await db.query(
  //     tableUser,
  //     columns: UserFields.values,
  //     where: '${UserFields.phone} = ?',
  //     whereArgs: [phone],
  //   );

  //   if (maps.isNotEmpty) {
  //     return User.fromJson(maps.first);
  //   } else {
  //     throw Exception('Phone Num $phone not found');
  //   }
  // }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
