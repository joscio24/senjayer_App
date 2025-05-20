import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Ajouter un contact", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Prénom", (value) => prenom = value!),
                _buildTextField("Nom", (value) => nom = value!),
                _buildTextField("Téléphone", (value) => telephone = value!, keyboardType: TextInputType.phone),
                _buildTextField("Email", (value) => email = value!, keyboardType: TextInputType.emailAddress, validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) return "Email invalide";
                  return null;
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Enregistrer"),
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

  Widget _buildTextField(String label, Function(String?) onSaved, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator ?? (value) => value!.isEmpty ? "Champ requis" : null,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes contacts", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        final contacts = controller.contacts;

        if (contacts.isEmpty) {
          return const Center(
            child: Text("Aucun contact disponible.", style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final initials = "${contact['prenom']?[0] ?? ''}${contact['nom']?[0] ?? ''}".toUpperCase();

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
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  "${contact['prenom']} ${contact['nom']}",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  "${contact['email']} • ${contact['telephone']}",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        backgroundColor: appTheme.appSlightViolet,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: "Ajouter un contact",
      ),
    );
  }
}
