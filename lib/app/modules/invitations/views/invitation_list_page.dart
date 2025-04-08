import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_cards.dart';
import 'package:senjayer/widgets/custom_textfield.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../contactInvite/views/contactList.dart';
import '../controllers/invitation_event_controller.dart';

class EventsViewInvites extends StatefulWidget {
  const EventsViewInvites({super.key});

  @override
  _EventsViewState createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsViewInvites> {
  late List<Map<String, dynamic>> invitations = [];

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  Future<void> _loadUserEvents() async {
    ApiService apiService = ApiService();

    // 1. Fetch events from API
    var eventsResponse = await apiService.getUsersEventsData();
    if (eventsResponse == null || !(eventsResponse["success"] as bool)) {
      print("Failed to load events: ${eventsResponse?["message"]}");
      return;
    }

    List eventList = (eventsResponse["events"] is List)
        ? eventsResponse["events"]
        : (eventsResponse["events"]["data"] ?? []);

    // 2. Open DB and fetch invitation counts for events
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts_event.db');
    final database = await openDatabase(path);

    // Query the database to get the count of invitations per event
    final List<Map<String, dynamic>> invitationCounts = await database.rawQuery('''
    SELECT event_id, COUNT(*) as invitation_count
    FROM invitations
    GROUP BY event_id
  ''');

    // Create a map for event_id to invitation count
    Map<String, int> eventInvitationCounts = {};
    for (var count in invitationCounts) {
      eventInvitationCounts[count['event_id']] = count['invitation_count'];
    }

    // 3. Filter events and add invitation count
    List filteredEvents = eventList.where((event) {
      return eventInvitationCounts.containsKey(event['id'].toString());
    }).toList();

    setState(() {
      invitations = filteredEvents.map((event) {
        return {
          "id": event["id"],
          "image": event["image_url"] ?? "assets/logoY.jpg",
          "title": event["name"] ?? "No Title",
          "location": event["event_address"] ?? "Unknown Location",
          "latitude": event["latitude"] ?? '0',
          "longitude": event["longitude"] ?? '0',
          "dateTime": _formatDate(event["start_date"], event["end_date"]),
          "endDate": _formatDate(event["end_date"], event["start_date"]),
          "description": event["description"] ?? "No description available",
          "status": event["status"]?.toString() ?? "Unknown status",
          "nbPlace": event["nb_place"]?.toString() ?? "0",
          "hasTicket": event["has_ticket"]?.toString() ?? "false",
          "ticketAvailable": event["ticket_available"]?.toString() ?? "false",
          "invitationCount": eventInvitationCounts[event['id'].toString()] ?? 0, // Add invitation count
        };
      }).toList();
    });

    print("Filtered Events with Invitations: $filteredEvents");
  }

  String _formatDate(String? startDateStr, String? endDateStr) {
    if (startDateStr == null || endDateStr == null) return "Unknown Date";

    DateTime startDate = DateTime.parse(startDateStr);
    DateTime endDate = DateTime.parse(endDateStr);

    String startFormatted =
        "${startDate.day} ${_monthName(startDate.month)} ${startDate.year}, "
        "${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}";

    String endFormatted =
        "${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}";

    return "$startFormatted - $endFormatted";
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return months[month - 1];
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String dayOfWeek = DateFormat('EEEE').format(now);
    String day = DateFormat('d').format(now);
    String month = DateFormat('MMMM').format(now);
    String year = DateFormat('yyyy').format(now);
    return '$dayOfWeek, $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = getFormattedDate();
    List<String> dateParts = formattedDate.split(", ");
    List<String> dayParts = dateParts[1].split(" ");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 20),
                  Image.asset("assets/logo.png", width: 70),
                  InkWell(
                    onTap: () => {},
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications,
                              color: Colors.black, size: 24),
                        ),
                        Positioned(
                          top: 8,
                          right: 10,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Center(child: TitleText_1(text: "Vos Évènements avec Invitations")),
              SizedBox(height: 20),

              // Events List
              Column(
                children:invitations.isEmpty
                    ? [ // If the invitations list is empty, show the "Aucune invitations reçues" text
                  Center(
                    child: Text(
                      "Aucune invitation envoyée",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
                    : invitations.map((invitation) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed('/user_events_details', arguments: invitation);
                    },
                    child: Stack(
                      children: [
                        EventCard(
                          evimage: invitation["image"]!,
                          title: invitation["title"]!,
                          location: invitation["location"]!,
                          dateTime: invitation["dateTime"]!,
                          description: invitation["description"]!,
                          endDate: invitation["endDate"]!,
                        ),
                        Positioned(
                          top: 15, // Adjust position to place it properly
                          right: 10, // Adjust position to place it properly
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                "/inviteContact",
                                arguments: {
                                  "id": invitation["id"].toString(),
                                  "description": invitation["description"].toString(),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: appTheme.appViolet, // Background color of the count badge
                                borderRadius: BorderRadius.circular(12), // Rounded corners
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.contacts, // Contact icon
                                    color: Colors.white,
                                    size: 16, // Icon size
                                  ),
                                  SizedBox(width: 4), // Space between icon and count
                                  Text(
                                    "${invitation["invitationCount"]}", // Invitation count
                                    style: TextStyle(
                                      color: Colors.white, // Text color
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {Get.toNamed("/user_events_create")},
        tooltip: 'Add Event',
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget buildBottomNavigation() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () => {Get.toNamed('/dashboard')},
          child: _buildNavItem("assets/home_icon.png", "Accueil"),
        ),
        InkWell(
          onTap: () => {Get.to(() => ListeContactsReseauPage())},
          child: _buildNavItem("assets/contacts_icon.png", "Mon réseau"),
        ),
      ],
    ),
  );
}

Widget _buildNavItem(String iconPath, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Image.asset(iconPath, width: 30),
          ),
        ],
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}
