import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_database_insertion/models/models.dart';

class DBHelper {
  /// Named parameterized Constructor
  DBHelper._();
  static final DBHelper dbHelper = DBHelper._();

  final String dbName = 'demo.db';
  final String tableName = 'students';

  final String colId = 'id';
  final String colName = 'name';
  final String colAge = 'age';
  final String colCity = 'city';
  final String colImage = 'image';

  Database? db;

  /// TODO: initialiseDB();

  Future<void> initDB() async {
    String directory = await getDatabasesPath();
    String path = join(directory, dbName);

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      String query =
          "CREATE TABLE IF NOT EXISTS $tableName ($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colName TEXT,$colAge INTEGER,$colCity TEXT,$colImage BLOB);";

      await db.execute(query);

      print("-----------------------------");
      print("Table created successfully");
      print("-----------------------------");
    });
  }

  /// TODO: insertRecord();
  Future<int> insertRecord({
    required String name,
    required int age,
    required String city,
    required Uint8List image,
  }) async {
    await initDB();

    // String name = 'Mansi';
    // String city = 'Anand';
    // int age = 19;
    /// Notes : VALUES(?,?) => Sql injection ....
    String query =
        "INSERT INTO $tableName($colName,$colAge,$colCity,$colImage) VALUES(?, ?, ?, ?);";
    List args = [
      name,
      age,
      city,
      image,
    ];

    int id = await db!.rawInsert(query, args);
    return id;
  }

  // TODO: fetchAllRecords();
  Future<List<Student>> fetchAllRecords() async {
    await initDB();

    String query = 'SELECT * FROM $tableName';

    List<Map<String, dynamic>> allStudents = await db!.rawQuery(query);

    List<Student> students =
        allStudents.map((e) => Student.fromMap(e)).toList();

    return students;
  }

  /// TODO: updateRecord();
  Future<int> updateRecord({
    required String name,
    required int age,
    required String city,
    required int id,
  }) async {
    await initDB();

    String query =
        'UPDATE $tableName SET $colName=?,$colAge=?,$colAge=?,$colCity=? WHERE $colId=?';
    List args = [name, age, city, id];

    return await db!.rawUpdate(query, args);
  }

  // TODO: deleteRecords();

  Future<int> deleteRecord({required int id}) async {
    await initDB();

    String query = 'DELETE FROM $tableName WHERE $colId=?';
    List args = [id];

    return await db!.rawDelete(query, args);
  }

  // TODO: fetchSearchedRecords();

  Future<List<Student>> fetchSearchedRecords({required String data}) async {
    await initDB();

    String query = "SELECT *From $tableName WHERE $colName LIKE '%$data%'";

    List<Map<String, dynamic>> allStudents = await db!.rawQuery(query);

    List<Student> students =
        allStudents.map((e) => Student.fromMap(e)).toList();

    return students;
  }
}
