import 'package:flutter/material.dart';
import 'package:senjayer/app/core/theme.dart';
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
      contacts = result ?? [];
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
          title: Text("Ajouter un contact", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField("Prénom", (value) => prenom = value),
                  _buildDialogTextField("Nom", (value) => nom = value),
                  _buildDialogTextField("Téléphone", (value) => telephone = value, type: TextInputType.phone),
                  _buildDialogTextField("Email", (value) => email = value, type: TextInputType.emailAddress),
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

  Widget _buildDialogTextField(String label, void Function(String) onSaved, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
        (value == null || value.trim().isEmpty) ? "Champ requis" : null,
        onSaved: (value) => onSaved(value!.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sélectionner un contact", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: contacts.isEmpty
            ? Center(child: Text("Aucun contact disponible."))
            : ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final prenom = contact['prenom'] ?? '';
            final nom = contact['nom'] ?? '';
            final email = contact['email'] ?? '';
            final telephone = contact['telephone'] ?? '';
            final initials = (prenom.isNotEmpty ? prenom[0] : '') + (nom.isNotEmpty ? nom[0] : '');

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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: appTheme.appSlightViolet,
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
                  icon: const Icon(Icons.person_add_alt_1, color: appTheme.appViolet),
                  onPressed: () => _inviteContact(contact['id']),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: Icon(Icons.add),
        tooltip: "Ajouter un contact",
      ),
    );
  }
}
