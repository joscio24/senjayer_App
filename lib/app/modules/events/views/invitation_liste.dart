import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/widgets/custom_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Invitation {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int invite_response;

  Invitation({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.invite_response,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      invite_response: json['invite_response'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'invite_response': invite_response,
  };
}

class InvitationListPage extends StatefulWidget {
  final String eventId;
  const InvitationListPage({super.key, required this.eventId});

  @override
  State<InvitationListPage> createState() => _InvitationListPageState();
}

class _InvitationListPageState extends State<InvitationListPage> {
  List<Invitation> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInvitations();
  }

  Future<void> loadInvitations() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'invitations_${widget.eventId}';

    // Load cached data if any
//     final cachedData = prefs.getString(key);
//     if (cachedData != null) {
//       final List decoded = jsonDecode(cachedData);
//       _invitations = decoded.map((e) => Invitation.fromJson(e)).toList();
// ;

//       setState(() => _isLoading = false);
//     }

    String? token = prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.senjayer.com/api/v1/events/invite/${widget.eventId}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body)['data'];
        _invitations =
            List<Map<String, dynamic>>.from(
              data,
            ).map((e) => Invitation.fromJson(e)).toList();

        await prefs.setString(
          key,
          jsonEncode(_invitations.map((e) => e.toJson()).toList()),
        );
      }
    } catch (e) {
      print("Erreur lors du chargement des invitations: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Invitations'),
        // backgroundColor: Colors.deepPurple,
      ),
      body:
          _isLoading
              ? Center(child: const CustomLoader())
              : _invitations.isEmpty
              ? Center(child: Text("Aucune invitation trouvée."))
              : ListView.builder(
                itemCount: _invitations.length,
                itemBuilder: (context, index) {
                  final inv = _invitations[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(inv.firstName[0]),
                      ),
                      title: Text('${inv.firstName} ${inv.lastName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(inv.email), Text(inv.phone)],
                      ),
                      trailing: Chip(
                        label: Text(
                          _getStatusText(inv.invite_response),
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(inv.invite_response),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return "En attente";
      case 2:
        return "Accepté";
      case 1:
        return "Rejeté";
      default:
        return "Inconnu";
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey.shade300;
      case 2:
        return Colors.green.shade200;
      case 1:
        return Colors.red.shade200;
      default:
        return Colors.blueGrey.shade200;
    }
  }
}
