import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sql;

class SqlHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    final database = await sql.openDatabase("dev.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });

    return database;
  }

  static Future<int> createItem(String title, String description) async {
    final db = await SqlHelper.db();

    final data = {'title': title, "description": description};

    final id = await db.insert("items", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> readAll() async {
    final db = await SqlHelper.db();

    final datas = await db.query("items");

    return datas;
  }

  static Future<void> updateItem(int id, String title, String description) async{
  final db = await SqlHelper.db();
  
  db.update("items",{'title':title, 'description':description, 'createdAt': DateTime.now().toString()}  ,  where: "id == ?", whereArgs: [id] );
  }

  static Future<void> delete(int id) async {
    final db = await SqlHelper.db();
    try {
      db.delete("items", where: "id == ?", whereArgs: [id]);
    } catch (err) {
      print(err);
    }
  }
}
