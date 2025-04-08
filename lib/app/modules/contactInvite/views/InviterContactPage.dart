import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'ListeContactsPage.dart';// à créer en dessous

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
        // ✅ S'assurer que les tables existent même si la DB existait déjà
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

  Future<void> _initDbs() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts_event.db');

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT,
            telephone TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE invitations (
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
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Souhaitez-vous retirer ce contact de la liste des invités ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await database.delete(
                'invitations',
                where: 'contact_id = ? AND event_id = ?',
                whereArgs: [contactId, event['id']],
              );
              Navigator.of(context).pop(); // Ferme le dialogue
              _loadInvitedContacts(); // Recharge la liste
            },
            child: const Text("Supprimer", style: TextStyle(color: appTheme.appWhite),),
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
        title: Text("Invités à ${event['description']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: invitedContacts.isEmpty
            ? Center(child: Text("Aucun contact encore invité."))
            : ListView.builder(
          itemCount: invitedContacts.length,
          itemBuilder: (context, index) {
            final contact = invitedContacts[index];
            final prenom = contact['prenom'] ?? '';
            final nom = contact['nom'] ?? '';
            final initials = (prenom.isNotEmpty ? prenom[0] : '') + (nom.isNotEmpty ? nom[0] : '');
            final email = contact['email'] ?? '';
            final telephone = contact['telephone'] ?? '';
            final contactId = contact['id'];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "$prenom $nom",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email),
                  Text(telephone),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmAndDelete(contactId, context),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => ListeContactsPage(
            database: database,
            event: event,
          ));
          _loadInvitedContacts(); // refresh after return
        },
        label: Text("Inviter"),
        icon: Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
