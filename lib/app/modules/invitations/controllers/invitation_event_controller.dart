import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InvitationController extends GetxController {
  RxList<Map<String, dynamic>> invitees = <Map<String, dynamic>>[].obs;
  late Database database;

  @override
  void onInit() {
    super.onInit();
    _initDb();
  }

  // Initialize local database
  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts_event.db');

    // Open the database
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            event_id INTEGER
          )
        ''');
      },
    );

    await loadInvitees();
  }

  // Load all invitees from local DB
  Future<void> loadInvitees() async {
    final result = await database.query('invitations');
    invitees.value = result;
  }

  // Get number of invitees for a specific event
  int getInviteCountForEvent(int eventId) {
    return invitees.where((c) => c['event_id'] == eventId).length;
  }

  // Add invitee to local DB (optional)
  Future<void> addInvitee(String name, String phone, int eventId) async {
    await database.insert('contacts', {
      'name': name,
      'phone': phone,
      'event_id': eventId,
    });
    await loadInvitees();
  }

  // Remove all invitees for a given event (optional)
  Future<void> removeInviteesByEvent(int eventId) async {
    await database.delete('contacts', where: 'event_id = ?', whereArgs: [eventId]);
    await loadInvitees();
  }

  // Clear entire table (optional, for reset/debugging)
  Future<void> clearAllInvitees() async {
    await database.delete('contacts');
    await loadInvitees();
  }
}
