import 'package:furcare/models/event.dart';
import 'package:furcare/models/pet.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Dbhelper {
  static const String dbName = 'furCare.db';
  static const int dbVersion = 3;
  static const String petsTb = 'pets';
  static const String petId = 'id';
  static const String petName = 'name';
  static const String petBreed = 'breed';
  static const String petAge = 'age';
  static const String petImage = 'imageUrl';
  static const String petNotes = 'notes';

  static const String eventsTb = 'events';
  static const String eventId = 'id';
  static const String eventPetId = 'petId';
  static const String eventTitle = 'title';
  static const String eventsDate = 'date';
  static const String isDone = 'isDone';

  static Future<Database> openDb() async {
    var path = join(await getDatabasesPath(), dbName);

    var createPetsTableSql = '''
      CREATE TABLE IF NOT EXISTS $petsTb(
        $petId INTEGER PRIMARY KEY AUTOINCREMENT,
        $petName TEXT NOT NULL,
        $petBreed TEXT,
        $petAge INTEGER,
        $petImage TEXT,
        $petNotes TEXT
      );
    ''';

    var createEventsTableSql = '''
      CREATE TABLE IF NOT EXISTS $eventsTb(
        $eventId INTEGER PRIMARY KEY AUTOINCREMENT,
        $eventPetId INTEGER,
        $eventTitle TEXT NOT NULL,
        $eventsDate TEXT NOT NULL,
        $isDone INTEGER DEFAULT 0, 
        FOREIGN KEY ($eventPetId) REFERENCES $petsTb ($petId)
      );
    ''';

    var db =
        await openDatabase(path, version: dbVersion, onCreate: (db, version) {
      db.execute(createPetsTableSql);
      db.execute(createEventsTableSql);
      print('Tables $petsTb & $eventsTb created');
    }, onUpgrade: (db, oldVersion, newVersion) {
      if (newVersion > oldVersion) {
        db.execute('DROP TABLE IF EXISTS $petsTb');
        db.execute('DROP TABLE IF EXISTS $eventsTb');
        db.execute(createPetsTableSql);
        db.execute(createEventsTableSql);
        print('Dropped and recreated tables $petsTb & $eventsTb');
      }
    });

    print('Database opened');
    return db;
  }

  static void addPet(Pet pet) async {
    var db = await openDb();
    var id = await db.insert(petsTb, pet.toMapWithoutId());
    print('inserted record with id: $id');
  }

  static void addEvent(Event event) async {
    var db = await openDb();
    var id = await db.insert(eventsTb, event.toMapWithoutId());
    print('inserted record with id: $id');
  }

  static void updateEvent(Event event) async {
    var db = await openDb();
    var id = await db.update(eventsTb, event.toMap(),
        where: '${eventId} = ?', whereArgs: [event.id]);
    print('updated record with id: $id');
    await db.close();
  }

  static Future<void> updateEventStatus(int eventId, int isDone) async {
    final db = await openDb();
    await db.update(
      'events',
      {'isDone': isDone},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  static Future<void> editPet(Pet pet) async {
    var db = await openDb();
    var id = await db.update(
      petsTb,
      pet.toMap(),
      where: '${petId} = ?',
      whereArgs: [pet.id],
    );

    var updatedRecord = await db.query(
      petsTb,
      where: '${petId} = ?',
      whereArgs: [pet.id],
    );

    if (updatedRecord.isNotEmpty) {
      print('Updated record: ${updatedRecord.first}');
    } else {
      print('No record found with id ${pet.id}');
    }

    await db.close();
  }

  static Future<List<Map<String, dynamic>>> fetchPets() async {
    var db = await openDb();
    return await db.query(petsTb);
  }

  static Future<List<Map<String, dynamic>>> fetchEvent() async {
    var db = await openDb();
    return await db.query(eventsTb);
  }

  static Future<List<Map<String, dynamic>>> getEventsByPetId(
      Event event) async {
    var db = await openDb();
    return await db.query(
      eventsTb,
      where: '${petId}',
      whereArgs: [event.petId],
    );
  }

  static Future<Map<String, dynamic>?> fetchPetById(int id) async {
    final db = await openDb();
    final result = await db.query(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.first;
  }

  static Future<void> deleteEvent(int eventId) async {
    var db = await openDb();
    await db.delete(
      eventsTb,
      where: 'id = ?',
      whereArgs: [eventId],
    );
    print('Deleted event with id: $eventId');
    await db.close();
  }

  static Future<void> deletePet(int petId) async {
    var db = await openDb();
    await db.delete(
      petsTb,
      where: 'id = ?',
      whereArgs: [petId],
    );
    print('Deleted pet with id: $petId');
    await db.close();
  }

  static Future<Map<String, dynamic>?> findPetByName(String petName) async {
    final db = await openDb();
    List<Map<String, dynamic>> results = await db.query(
      'pets',
      where: 'name = ?',
      whereArgs: [petName.toLowerCase()],
    );

    return results.isNotEmpty ? results.first : null;
  }

  static Future<List<Map<String, dynamic>>> fetchTodayEvents() async {
    final db = await openDb();
    final now = DateTime.now();

    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfDayString = DateFormat('yyyy-MM-dd HH:mm').format(startOfDay);

    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);
    final endOfDayString = DateFormat('yyyy-MM-dd HH:mm').format(endOfDay);

    return await db.query(
      eventsTb,
      where: '$eventsDate BETWEEN ? AND ?',
      whereArgs: [startOfDayString, endOfDayString],
    );
  }

  static Future<List<Map<String, dynamic>>> fetchPetEvents(int petId) async {
    final db = await openDb();
    return await db.query(
      'events',
      where: 'petId = ?',
      whereArgs: [petId],
    );
  }

  static Future<String?> fetchPetNameById(int petId) async {
    final db = await openDb();
    final result = await db.query(
      'pets',
      columns: [petName],
      where: 'id = ?',
      whereArgs: [petId],
    );
    return result.isNotEmpty ? result.first[petName] as String : null;
  }
}
