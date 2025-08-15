import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/app/modules/events/views/invitation_liste.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ContactItem {
  String firstName;
  String lastName;
  String phone;
  String email;
  int id;
  int quantity;

  ContactItem({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.id,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "email": email,
    "id": id,
    "quantity": quantity,
  };
}

class ContactsInvitePage extends StatefulWidget {
  final int eventId;
  final int ticketId;

  const ContactsInvitePage({
    super.key,
    required this.eventId,
    required this.ticketId,
  });

  @override
  State<ContactsInvitePage> createState() => _ContactsInvitePageState();
}

class _ContactsInvitePageState extends State<ContactsInvitePage> {
  List<Contact> phoneContacts = [];
  Map<String, String> emailInputs = {};
  Set<Contact> selectedContacts = {};
  String? invitedBy;
  List<String> invitedByOptions = [];

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchContacts();
    fetchInvitedByOptions();

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  Future<void> fetchContacts() async {
    final granted = await FlutterContacts.requestPermission();
    // if () {
    //   Get.snackbar(
    //     "Permission refusée",
    //     "Autorisez l'accès aux contacts pour continuer.",
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    //   return;
    // }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    setState(() {
      phoneContacts = contacts;
    });
  }

  Future<void> fetchInvitedByOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse(
        'https://api.senjayer.com/api/v1/events/show-list/${widget.eventId}',
      ),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      invitedByOptions = List<String>.from(data["data"]);
      invitedBy = invitedByOptions.isNotEmpty ? invitedByOptions.first : null;
    } else {
      Get.snackbar(
        "Erreur",
        "Impossible de récupérer les invitants",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    setState(() {});
  }

  bool _hasEmail(Contact contact) {
    return contact.emails.isNotEmpty && contact.emails.first.address.isNotEmpty;
  }

  String? _getPhone(Contact contact) {
    if (contact.phones.isNotEmpty) {
      return contact.phones.first.number;
    }
    return null;
  }

  void toggleSelection(Contact contact) {
    final hasEmail =
        _hasEmail(contact) || (emailInputs[contact.id]?.isNotEmpty ?? false);

    if (!hasEmail) {
      Get.snackbar(
        "Email manquant",
        "Ajoutez un email avant de sélectionner ce contact",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
  }

  Future<void> sendInvitations() async {
    if (selectedContacts.isEmpty) {
      Get.snackbar(
        "Erreur",
        "Aucun contact sélectionné",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final userJson = prefs.getString("user");

    if (token == null || userJson == null || invitedBy == null) {
      List<String> missing = [];

      if (token == null) missing.add("token");
      if (userJson == null) missing.add("utilisateur");
      if (invitedBy == null) missing.add("invité par");

      Get.snackbar(
        "Erreur",
        "Données manquantes : ${missing.join(', ')}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final userMap = jsonDecode(userJson);
    final userId = userMap['id'];

    final items =
        selectedContacts.map((contact) {
          final email =
              _hasEmail(contact)
                  ? contact.emails.first.address
                  : emailInputs[contact.id] ?? "";
          final phone = _getPhone(contact) ?? "";

          return ContactItem(
            firstName: contact.name.first,
            lastName: contact.name.last,
            phone: phone,
            email: email,
            id: widget.ticketId,
          );
        }).toList();

    final body = {
      "user_id": userId,
      "firstName": "default",
      "lastName": "default",
      "phone": "22900000000",
      "amount": 0,
      "price": 0,
      "operator": "MTN",
      "invited_by": invitedBy,
      "items": items.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('https://api.senjayer.com/api/v1/transactions?private=1'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar(
        "Succès",
        "Invitations envoyées avec succès",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.to(() => InvitationListPage(eventId: widget.eventId.toString()));
    } else {
      Get.snackbar(
        "Erreur",
        "Échec de l'envoi des invitations",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts =
        phoneContacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phone = _getPhone(contact)?.toLowerCase() ?? '';
          final email =
              contact.emails.isNotEmpty
                  ? contact.emails.first.address.toLowerCase()
                  : (emailInputs[contact.id]?.toLowerCase() ?? '');
          return name.contains(searchQuery) ||
              phone.contains(searchQuery) ||
              email.contains(searchQuery);
        }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Sélectionner les contacts")),
      body: Column(
        children: [

          Text("Veuillez ajouter de mail a vos contact sans email avant envoi d'invitation"),
          SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Rechercher par nom, email ou téléphone",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (invitedByOptions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButtonFormField<String>(
                value: invitedBy,
                items:
                    invitedByOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => invitedBy = val),
                decoration: const InputDecoration(labelText: "Invité par"),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                final email =
                    _hasEmail(contact)
                        ? contact.emails.first.address
                        : (emailInputs[contact.id] ?? "");
                final phone = _getPhone(contact) ?? "";
                final isSelected = selectedContacts.contains(contact);

                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (_) => toggleSelection(contact),
                    ),
                    title: Text(contact.displayName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (phone.isNotEmpty) Text("Téléphone: $phone"),
                        if (email.isNotEmpty) Text("Email: $email"),
                        if (!_hasEmail(contact))
                          TextField(
                            decoration: const InputDecoration(
                              labelText: "Veuillez Ajouter un mail pour ce contact",
                              isDense: true,
                            ),
                            onChanged: (val) {
                              emailInputs[contact.id] = val;
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: sendInvitations,
            icon: const Icon(Icons.send, color: appTheme.appWhite),
            label: const Text("Envoyer les invitations"),
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.appViolet,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
