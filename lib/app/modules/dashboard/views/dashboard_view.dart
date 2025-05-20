import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/app/modules/auth/views/login_view.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../contactInvite/views/contactList.dart';
import '../../events/views/events_view.dart';
import '../../invitations/views/invitation_list_page.dart';

import 'package:path/path.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State {
  // final email_controller = TextEditingController();

  ApiService apiService = ApiService();

  String userName = "Loading...";
  String email = "Loading...";
  String profileImage = "";
  String inviteCount = "";
  String eventCount = "";
  String sentInviteCount = "";
  int totalInvitations = 0;
  late List<Map<String, dynamic>> invitations = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _loadUserData();
    _loadUserEventsInvited();
    _loadUserEvents();
    _loadTotalInvitations();

    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _loadUserData();
      _loadUserEventsInvited();
      _loadUserEvents();
      _loadTotalInvitations();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    var userData = await apiService.getUserData();
    if (userData != null) {
      print(userData["user"]["firstName"]?.toString() ?? "Unknown User");
      setState(() {
        userName = userData["user"]["firstName"]?.toString() ?? "_unknown";
        email = userData["user"]["firstName"]?.toString() ?? "...";
        profileImage = userData["user"]["image_url"]?.toString() ?? "...";
      });
    }
  }

  Future<void> _loadUserEventsInvited() async {
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

    List filteredEvents = eventList.where((event) {
      return event["private"] == 1;

    }).toList();

    setState(() {
      inviteCount = filteredEvents.length.toString();
      invitations =
          filteredEvents.map((event) {
            return {
              "image":
                  event["image_url"] ??
                  "assets/default.png", // Default image if missing
              "title": event["name"] ?? "No Title",
              "location": event["event_address"] ?? "Unknown Location",
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

  Future<void> _loadUserEvents() async {
    ApiService apiService = ApiService();
    var eventsResponse = await apiService.getUsersEventsData();

    if (eventsResponse == null || !(eventsResponse["success"] as bool)) {
      print("Failed to load events: ${eventsResponse?["message"]}");
      return;
    }

    List eventList =
        (eventsResponse["events"] is List)
            ? eventsResponse["events"] // Direct list
            : (eventsResponse["events"]["data"] ?? []);
    List filteredEvents = eventList.where((event) {
      return event["private"] == 1;

    }).toList();

    setState(() {
      eventCount = filteredEvents.length.toString();
      invitations =
          filteredEvents.map((event) {
            return {
              "image":
                  event["image_url"] ??
                  "assets/default.png", // Default image if missing
              "title": event["name"] ?? "No Title",
              "location": event["event_address"] ?? "Unknown Location",
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

  Future<void> _loadTotalInvitations() async {
    int count = await _getTotalInvitationCount();
    setState(() {
      totalInvitations = count;
    });
  }

  Future<int> _getTotalInvitationCount() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts_event.db');
    final database = await openDatabase(path);

    // Query the database to get the total count of invitations
    final List<Map<String, dynamic>> totalInvitations = await database.rawQuery('''
    SELECT COUNT(*) as total_invites
    FROM invitations
  ''');

    // Return the total count
    return totalInvitations.isNotEmpty ? totalInvitations.first['total_invites'] ?? 0 : 0;
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

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user");

    // Navigate to login screen after logout
    Get.offAll(() => LoginView());
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = getFormattedDate();
    List<String> dateParts = formattedDate.split(", ");
    List<String> dayParts = dateParts[1].split(" ");

    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false, // Prevents back navigation
        onPopInvoked: (didPop) {
          if (didPop) return; // If another pop is invoked, do nothing

          // Show exit confirmation dialog
          Get.defaultDialog(
            title: "Quiter l'application",
            middleText: "Voulez-vous vraiment quitter l'application?",
            textConfirm: "Oui",
            textCancel: "Non",
            onConfirm: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // Close app on Android
              } else {
                exit(0); // Close app on iOS
              }
            },
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 60),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text("Compte", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset("assets/user.png", width: 70),
                                    SizedBox(height: 10),
                                    Text(
                                      'Salut',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          userName,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        logout();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text(
                                        "Se déconnecter",
                                        style: TextStyle(color: appTheme.appWhite),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("assets/user.png", width: 60),
                            SizedBox(width: 10),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.55,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Salut',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        userName,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => Get.toNamed('/user_search'),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            onTap: () => Get.toNamed("/notifications"),
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
                    ],
                  ),
                ),




                // Date
                SizedBox(height: 40),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0), // Small padding, no extra spacing
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          dateParts[0], // e.g., "Monday"
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 6), // Small spacing between texts
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          "${dayParts[0]} ${dayParts[1]} ${dayParts[2]}", // e.g., "01 January 2025"
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => {Get.toNamed('/invitations')},
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width * 0.42,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1, color: Colors.black26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invitations Reçues",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              // , // Ensures text doesn't get cut off
                            ),
                            SizedBox(height: 5),
                            Text(
                              "$inviteCount invitations reçues",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.purple,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(height: 15),
                            Container(
                              // Ensures full width
                              child: Align(
                                alignment:
                                    Alignment
                                        .centerRight, // Moves the image to the right
                                child: Image.asset(
                                  "assets/invitation_icon.png", // Replace with your asset path
                                  width: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: (){
                        Get.to(() => EventsViewInvites());
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width * 0.42,
                        decoration: BoxDecoration(
                          color: appTheme.appViolet,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1, color: Colors.black26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invitations Envoyées",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              // , // Ensures text doesn't get cut off
                            ),
                            SizedBox(height: 5),
                            Text(
                              "$totalInvitations invitations envoyées...",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(height: 15),
                            Container(
                              // Ensures full width
                              child: Align(
                                alignment:
                                    Alignment
                                        .centerRight, // Moves the image to the right
                                child: Image.asset(
                                  "assets/invite_send.png", // Replace with your asset path
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => {Get.toNamed("/user_events")},
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width * 0.42,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 17, 2, 33),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1, color: Colors.black26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Évènements",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              // , // Ensures text doesn't get cut off
                            ),
                            SizedBox(height: 5),
                            Text(
                              "$eventCount évènements ",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(height: 15),
                            Container(
                              // Ensures full width
                              child: Align(
                                alignment:
                                    Alignment
                                        .centerRight, // Moves the image to the right
                                child: Image.asset(
                                  "assets/contacts_icon.png", // Replace with your asset path
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => {Get.toNamed("/parametres")},
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width * 0.42,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1, color: Colors.black26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mon profil",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              // , // Ensures text doesn't get cut off
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Voir mon profil",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 20, 20, 20),
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(height: 15),
                            Container(
                              // Ensures full width
                              child: Align(
                                alignment:
                                    Alignment
                                        .centerRight, // Moves the image to the right
                                child: Image.asset(
                                  "assets/user_icon.png", // Replace with your asset path
                                  width: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),



                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 16),
                    //   child: Text("Événements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    // ),
                    _buildEventActions(),
                    SizedBox(height: 20),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Offres partenaires :",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                          softWrap: true,
                        ),
                        Container(
                          height: 4,
                          width:
                          MediaQuery.of(context).size.width *
                              0.5, // Adjust thickness of the underline
                          color: appTheme.appViolet,
                          // padding: EdgeInsets.all(1), // Underline color
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),
                InkWell(
                  onTap: () => {},
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage("assets/bg.jpg"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Logo
              ],
            ),
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
      preferredSize: Size.fromHeight(kToolbarHeight),
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
                    onTap: () => Get.toNamed('/user_search'),
                    child: Icon(Icons.search, color: Colors.grey, size: 28),
                  ),
                  SizedBox(width: 20),
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
          onTap: () => {},
          child: _buildNavItem("assets/home_icon.png", "Accueil"),
        ),
        InkWell(
          onTap:
              () => {
                Get.to(() => ListeContactsReseauPage())
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

Widget _buildEventActions() {
  final items = [
    {
      'label': 'Créer',
      'icon': Icons.add_circle,
      'color': Colors.orange,
      'route': '/user_events_packs',
    },
    // {
    //   'label': 'Stats',
    //   'icon': Icons.pie_chart,
    //   'color': Colors.redAccent,
    //   'route': '/stats',
    // },
    {
      'label': 'Contrôle',
      'icon': Icons.verified_user,
      'color': Colors.teal,
      'route': '/control',
    },
    {
      'label': 'Scan',
      'icon': Icons.qr_code_scanner,
      'color': Colors.indigo,
      'route': '/scan',
    },
    // {
    //   'label': 'Retrait',
    //   'icon': Icons.attach_money,
    //   'color': Colors.green,
    //   'route': '/retrait',
    // },
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: items.map((item) {
        return GestureDetector(

          onTap: () => Get.toNamed(item['route'] as String),
          child: Container(

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,

              border: Border.all(color: Colors.grey.shade200),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.02),
              //     blurRadius: 6,
              //     offset: const Offset(0, 2),
              //   ),
              // ],

              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: (item['color'] as Color).withOpacity(0.1),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
}
