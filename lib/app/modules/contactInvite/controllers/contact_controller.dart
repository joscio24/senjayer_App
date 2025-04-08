import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactController extends GetxController {
  late Database database;
  var contacts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts_event.db');

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT,
            telephone TEXT
          )
        ''');
      },
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT,
            telephone TEXT
          )
        ''');
      },
    );

    loadContacts();
  }

  Future<void> loadContacts() async {
    final result = await database.query('contacts');
    contacts.value = result;
  }

  Future<void> addContact(String nom, String prenom, String email, String telephone) async {
    await database.insert('contacts', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
    });
    loadContacts(); // Refresh after insert
  }
}
