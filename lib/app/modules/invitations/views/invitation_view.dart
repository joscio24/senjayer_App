import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_cards.dart';
import 'package:senjayer/widgets/custom_textfield.dart';
import 'package:intl/intl.dart';

class InvitationView extends StatefulWidget {
  const InvitationView({super.key});

  @override
  _InvitationViewState createState() => _InvitationViewState();
}

class _InvitationViewState extends State<InvitationView> {
  // final email_controller = TextEditingController();

  late List<Map<String, dynamic>> invitations = [];

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  Future<void> _loadUserEvents() async {
    ApiService apiService = ApiService();
    var eventsResponse = await apiService.getEventsData();

    if (eventsResponse == null || !(eventsResponse["success"] as bool)) {
      print("Failed to load events: ${eventsResponse?["message"]}");
      return;
    }

    List eventList =
        (eventsResponse["events"] is List)
            ? eventsResponse["events"] // Direct list
            : (eventsResponse["events"]["data"] ?? []);

    setState(() {
      invitations =
          eventList.map((event) {
            return {
              "image":
                  event["image_url"] ??
                  "assets/default.png", // Default image if missing
              "title": event["name"] ?? "No Title",
              "location": event["event_address"] ?? "Unknown Location",
              "latitude": event["latitude"] ?? '29379907',
              "longitude": event["longitude"] ?? '29379907',
              "dateTime": _formatDate(
                event["start_date"],
                event["end_date"],
              ), // Format date properly
              "endDate": _formatDate(
                event["end_date"],
                event["start_date"],
              ), // Optional: end date if needed
              "description":
                  event["description"] ??
                  "No description available", // Optional: description
              "status":
                  event["status"]?.toString() ??
                  "Unknown status", // Optional: status
              "nbPlace":
                  event["nb_place"]?.toString() ??
                  "0", // Optional: number of places
              "hasTicket":
                  event["has_ticket"]?.toString() ??
                  "false", // Optional: has tickets
              "ticketAvailable":
                  event["ticket_available"]?.toString() ??
                  "false", // Optional: ticket availability
            };
          }).toList();

      print("Invitations: $invitations");
    });
  }

  // Format date from API (e.g., "2024-04-01T17:00:00.000000Z" → "01 April 2024, 17:00")
  String _formatDate(String? startDateStr, String? endDateStr) {
    if (startDateStr == null || endDateStr == null) return "Unknown Date";

    // Parse start and end dates
    DateTime startDate = DateTime.parse(startDateStr);
    DateTime endDate = DateTime.parse(endDateStr);

    // Format the start and end time
    String startFormatted =
        "${startDate.day} ${_monthName(startDate.month)} ${startDate.year}, "
        "${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}";

    String endFormatted =
        "${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}";

    // Return combined formatted string
    return "$startFormatted-$endFormatted";
  }

  // Get month name from number
  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    // Format the date to the required format
    String dayOfWeek = DateFormat(
      'EEEE',
    ).format(now); // EEEE returns the full name of the day
    String day = DateFormat('d').format(now); // d returns the day of the month
    String month = DateFormat(
      'MMMM',
    ).format(now); // MMMM returns the full name of the month
    String year = DateFormat('yyyy').format(now); // yyyy returns the year

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
                          child: Icon(
                            Icons.notifications,
                            color: Colors.black,
                            size: 24,
                          ),
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

              TitleText_1(text: "Vos Invitations"),

              SizedBox(height: 20),

              Column(
                children: invitations.isEmpty
                    ? [ // If the invitations list is empty, show the "Aucune invitations reçues" text
                  Center(
                    child: Text(
                      "Aucune invitations reçues",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
                    : invitations.map((invitation) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        '/invitation_details',
                        arguments: invitation,
                      );
                    },
                    child: InvitationCard(
                      evimage: invitation["image"]!,
                      title: invitation["title"]!,
                      location: invitation["location"]!,
                      dateTime: invitation["dateTime"]!,
                      description: invitation["description"]!,
                      endDate: invitation["endDate"]!,
                    ),
                  );
                }).toList(),
              )


              // Logo
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}

class AppBarSection extends StatelessWidget implements PreferredSizeWidget {
  const AppBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight2),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.white, // Set AppBar background color
          // boxShadow: [
          //   BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
          // ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: User Info
              Row(
                children: [
                  Image.asset("assets/user.png", width: 50),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salut',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        'Joseph',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right Section: Icons
              Row(
                children: [
                  InkWell(
                    onTap: () => {},
                    child: Icon(Icons.search, color: Colors.grey, size: 28),
                  ),
                  SizedBox(width: 10),
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
                          child: Icon(
                            Icons.notifications,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight2);
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
          onTap:
              () => {
                // tobechanged
                Get.toNamed('/invitations'),
              },
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
