import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ListeContactsPage extends StatefulWidget {
  final Database? database;
  final Map<String, String>? event;

  const ListeContactsPage({this.database, this.event, Key? key}) : super(key: key);

  @override
  State<ListeContactsPage> createState() => _ListeContactsPageState();
}


class _ListeContactsPageState extends State<ListeContactsPage> {
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContactsNotInvited();
  }




  Future<void> _loadContactsNotInvited() async {
    final result = await widget.database?.rawQuery('''
      SELECT * FROM contacts WHERE id NOT IN (
        SELECT contact_id FROM invitations WHERE event_id = ?
      )
    ''', [widget.event?['id']]);

    setState(() {
      contacts = result!;
    });
  }

  Future<void> _inviteContact(int contactId) async {
    await widget.database?.insert('invitations', {
      'contact_id': contactId,
      'event_id': widget.event?['id'],
      'event_name': widget.event?['description'] ?? '',
    });

    _loadContactsNotInvited();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contact invité.")),
    );
  }

  void _showAddContactDialog() {
    final _formKey = GlobalKey<FormState>();
    String nom = '', prenom = '', email = '', telephone = '';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Ajouter un contact"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "Prénom"),
                    validator: (value) =>
                    value!.isEmpty ? "Champ requis" : null,
                    onSaved: (value) => prenom = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Nom"),
                    validator: (value) =>
                    value!.isEmpty ? "Champ requis" : null,
                    onSaved: (value) => nom = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Téléphone"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                    value!.isEmpty ? "Champ requis" : null,
                    onSaved: (value) => telephone = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@')
                        ? "Email invalide"
                        : null,
                    onSaved: (value) => email = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Enregistrer"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await widget.database?.insert('contacts', {
                    'nom': nom,
                    'prenom': prenom,
                    'email': email,
                    'telephone': telephone,
                  });
                  Navigator.pop(context);
                  _loadContactsNotInvited();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sélectionner un contact"),
      ),
      body: contacts.isEmpty
          ? Center(child: Text("Aucun contact disponible."))
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            title: Text("${contact['prenom']} ${contact['nom']}"),
            subtitle: Text(contact['email']),
            trailing: IconButton(
              icon: Icon(Icons.person_add_alt),
              onPressed: () => _inviteContact(contact['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: Icon(Icons.add),
        tooltip: "Ajouter un contact",
      ),
    );
  }
}
