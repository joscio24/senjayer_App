import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'ListeContactsPage.dart';

class InviterContactsPage extends StatefulWidget {
  @override
  State<InviterContactsPage> createState() => _InviterContactsPageState();
}

class _InviterContactsPageState extends State<InviterContactsPage> {
  late Database database;
  List<Map<String, dynamic>> invitedContacts = [];
  final Map<String, String> event = Get.arguments;

  @override
  void initState() {
    super.initState();
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS invitations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contact_id INTEGER,
            event_id TEXT,
            event_name TEXT
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS invitations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contact_id INTEGER,
            event_id TEXT,
            event_name TEXT
          )
        ''');
      },
    );

    _loadInvitedContacts();
  }

  void _confirmAndDelete(int contactId, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Retirer ce contact ?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: const Text("Souhaitez-vous retirer ce contact de la liste des invités ?"),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await database.delete(
                'invitations',
                where: 'contact_id = ? AND event_id = ?',
                whereArgs: [contactId, event['id']],
              );
              Navigator.pop(context);
              _loadInvitedContacts();
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadInvitedContacts() async {
    final result = await database.rawQuery('''
      SELECT c.* FROM contacts c
      INNER JOIN invitations i ON c.id = i.contact_id
      WHERE i.event_id = ?
    ''', [event['id']]);

    setState(() {
      invitedContacts = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invités : ${event['description']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: invitedContacts.isEmpty
            ? const Center(
          child: Text("Aucun contact encore invité.", style: TextStyle(fontSize: 16)),
        )
            : ListView.builder(
          itemCount: invitedContacts.length,
          itemBuilder: (context, index) {
            final contact = invitedContacts[index];
            final prenom = contact['prenom'] ?? '';
            final nom = contact['nom'] ?? '';
            final initials = "${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}".toUpperCase();
            final email = contact['email'] ?? '';
            final telephone = contact['telephone'] ?? '';
            final contactId = contact['id'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: appTheme.appSlightViolet,
                  child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text("$prenom $nom", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    Text(telephone, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmAndDelete(contactId, context),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => ListeContactsPage(database: database, event: event));
          _loadInvitedContacts();
        },
        backgroundColor: appTheme.appSlightViolet,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Inviter", style: TextStyle(color: appTheme.appWhite),),
      ),
    );
  }
}
