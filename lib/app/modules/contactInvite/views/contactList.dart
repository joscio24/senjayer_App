import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

class ListeContactsReseauPage extends StatelessWidget {
  final controller = Get.put(ContactController());

  ListeContactsReseauPage({super.key});

  void _showAddContactDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String nom = '', prenom = '', email = '', telephone = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ajouter un contact"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Prénom"),
                  validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  onSaved: (value) => prenom = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Nom"),
                  validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  onSaved: (value) => nom = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Téléphone"),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  onSaved: (value) => telephone = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  value!.isEmpty || !value.contains('@')
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
                await controller.addContact(nom, prenom, email, telephone);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des contacts")),
      body: Obx(() {
        final contacts = controller.contacts;

        if (contacts.isEmpty) {
          return const Center(child: Text("Aucun contact disponible."));
        }

        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final initials = "${contact['prenom']?[0] ?? ''}${contact['nom']?[0] ?? ''}";
            return ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                "${contact['prenom']} ${contact['nom']}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "${contact['email']} • ${contact['telephone']}",
                style: TextStyle(color: Colors.grey[700]),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: const Icon(Icons.add),
        tooltip: "Ajouter un contact",
      ),
    );
  }
}
