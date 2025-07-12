import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactItem {
  String firstName;
  String lastName;
  String phone;
  String email;
  int ticketId;
  int quantity;

  ContactItem({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.ticketId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "email": email,
    "id": ticketId,
    "quantity": quantity,
  };
}

class InviteDialogExample extends StatelessWidget {
  final int eventId;
  final int ticketId;

  InviteDialogExample({
    super.key,
    required this.eventId,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inviter à l'événement")),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: MainButtons(
            onPressed: () => showInviteDialog(context, eventId),
            text: "Ajouter des invités",
          ),
        ),
      ),
    );
  }

  // Inside showInviteDialog()
  void showInviteDialog(BuildContext context, int eventId) {
    List<ContactItem> contactItems = [];

    TextEditingController firstNameCtrl = TextEditingController();
    TextEditingController lastNameCtrl = TextEditingController();
    TextEditingController phoneCtrl = TextEditingController();
    TextEditingController emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Ajouter des invités"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: firstNameCtrl,
                      decoration: InputDecoration(labelText: "Prénom"),
                    ),
                    TextField(
                      controller: lastNameCtrl,
                      decoration: InputDecoration(labelText: "Nom"),
                    ),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(labelText: "Téléphone"),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (firstNameCtrl.text.isNotEmpty &&
                            lastNameCtrl.text.isNotEmpty &&
                            phoneCtrl.text.isNotEmpty) {
                          contactItems.add(
                            ContactItem(
                              firstName: firstNameCtrl.text,
                              lastName: lastNameCtrl.text,
                              phone: phoneCtrl.text,
                              email: emailCtrl.text,
                              ticketId: ticketId, // ✅ Use from widget
                            ),
                          );

                          setState(() {
                            firstNameCtrl.clear();
                            lastNameCtrl.clear();
                            phoneCtrl.clear();
                            emailCtrl.clear();
                          });
                        }
                      },
                      child: Text("Ajouter à la liste"),
                    ),
                    Divider(),
                    Text("Invités ajoutés: ${contactItems.length}"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await sendInvitation(eventId, contactItems);
                    Navigator.of(context).pop();
                  },
                  child: Text("Envoyer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> sendInvitation(int eventId, List<ContactItem> items) async {
    if (items.isEmpty) {
      Get.snackbar("Erreur", "Aucun invité à envoyer");
      return;
    }

    final body = {
      "user_id": 1, // Replace with actual user ID
      "phone": "229016165478",
      "amount": 0,
      "operator": "MTN",
      "invited_by": "You", // Replace with actual inviter
      "items": items.map((e) => e.toJson()).toList(),
    };

    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    try {
      final response = await http.post(
        Uri.parse('https://api.senjayer.com/api/v1/transactions'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Succès", "Invitations envoyées avec succès");
      } else {
        print("Erreur: ${response.body}");
        Get.snackbar("Erreur", "Impossible d'envoyer les invitations");
      }
    } catch (e) {
      print("Exception: $e");
      Get.snackbar("Erreur", "Une erreur est survenue");
    }
  }
}
