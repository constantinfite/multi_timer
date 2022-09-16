import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseConnection {
  setDatabaseTimer() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_timerlist_sqflite');
    var database = await openDatabase(path,
        version: 1, onCreate: _onCreatingDatabaseTimer);
    return database;
  }

  _onCreatingDatabaseTimer(Database database, int version) async {
    await database
        .execute("CREATE TABLE timers(id INTEGER PRIMARY KEY, duration INTEGER)");
  }
}
