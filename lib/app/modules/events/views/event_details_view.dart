import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/app/modules/events/views/addticket.dart';
import 'package:senjayer/app/modules/events/views/create_invitation.dart';
import 'package:senjayer/app/modules/events/views/invitation_liste.dart';
import 'package:senjayer/utils/toot_icon.dart';
import 'package:senjayer/utils/tutorial_helper.dart';
import 'package:senjayer/widgets/custom_addtocalendar.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_cards.dart';
import 'package:senjayer/widgets/custom_reject_dialog.dart';
import 'package:senjayer/widgets/custom_success_dialog.dart';
import 'package:senjayer/widgets/custom_textfield.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../../../../imageview/imageViewPage.dart';
import '../../contactInvite/views/ListeContactsPage.dart';
import 'package:permission_handler/permission_handler.dart';

class EventDetailsView extends StatefulWidget {
  @override
  EventDetailsViewState createState() => EventDetailsViewState();

  EventDetailsView({super.key});
}

class EventDetailsViewState extends State<EventDetailsView> {
  @override
  void initState() {
    super.initState();

    _checkFirstTimeAndShowTutorial();
  }

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

  String getFormattedDate(dateTimeStr) {
    DateTime now = DateTime.parse(dateTimeStr);
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

  final Map<String, dynamic> invitation = Get.arguments;

  // String formattedDate = getFormattedDate();
  // List<String> dateParts = formattedDate.split(", ");

  Future<bool> _requestCalendarPermission() async {
    var status = await Permission.calendarWriteOnly.status;
    if (!status.isGranted) {
      status = await Permission.calendarWriteOnly.request();
    }
    return status.isGranted;
  }

  void _addEventToCalendar(BuildContext context) async {
    bool granted = await _requestCalendarPermission();
    if (!granted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Permission calendrier refusée')));
      return;
    }

    final dateTimeRange = invitation['dateTime'] as String? ?? '';

    try {
      final parts = dateTimeRange.split(',');
      if (parts.length != 2) throw FormatException('Invalid date format');

      final dateStr = parts[0].trim(); // e.g. "11 Jun 2025"
      final timeRangeStr = parts[1].trim(); // e.g. "1:23-1:23"

      final timeParts = timeRangeStr.split('-');
      if (timeParts.length != 2) throw FormatException('Invalid time format');

      final startTimeStr = timeParts[0].trim(); // e.g. "1:23"
      final endTimeStr = timeParts[1].trim(); // e.g. "1:23"

      final date = DateFormat("d MMM yyyy").parse(dateStr);
      final startTime = DateFormat("H:mm").parse(startTimeStr);
      final endTime = DateFormat("H:mm").parse(endTimeStr);

      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      final endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      final event = Event(
        title: invitation["title"] ?? 'Événement',
        description: '',
        location: invitation["location"] ?? '',
        startDate: startDateTime,
        endDate: endDateTime,
        allDay: false,
      );

      Add2Calendar.addEvent2Cal(event).then((success) {
        print("Add2Calendar success? $success");
        if (success) {
          showCustomAddSuccessDialog(
            context,
            "Ajouté avec succès au calendrier",
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('L’ajout au calendrier a échoué')),
          );
        }
      });
    } catch (e) {
      print('Error parsing date/time: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Format de date invalide')));
    }
  }

  bool _showInfoButton = false;

  final GlobalKey addToCalendar = GlobalKey();
  final GlobalKey seeMap = GlobalKey();
  final GlobalKey details = GlobalKey();
  final GlobalKey invited = GlobalKey();
  final GlobalKey inviteNew = GlobalKey();

  Future<void> _checkFirstTimeAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool("hasSeenCreateTutorial") ?? false;

    if (!hasSeenTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorial();
      });
      prefs.setBool("hasSeenCreateTutorial", true);
    } else {
      setState(() => _showInfoButton = true);
    }
  }

  void _showTutorial() {
    showAppTutorial(
      context: context,
      targets: [addToCalendar, seeMap, details, inviteNew, invited],
      descriptions: [
        "Cliquez ici pour ajouter l'évènement à votre google agenda.",
        "Cliquez ici pour voir le lieux de l'évènement sur google maps.",
        "Créer ici votre ticket pour l'évènement",
        "Ensuite vous pouvez inviter ici vos contacts à votre évènement privé.",
        "Consultez la liste de vos invités.",
      ],
      onFinish: () => setState(() => _showInfoButton = true),
      onSkip: () => setState(() => _showInfoButton = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    String transformToFirebaseUrl(String url) {
      if (url.startsWith('https://storage.cloud.google.com/')) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;

        // Extract the bucket and the path to the file
        final bucket = pathSegments.first; // summer-monument-389019.appspot.com
        final filePath = pathSegments
            .skip(1)
            .join('/'); // event-images/1749588617_1000088084.jpg
        final encodedPath = Uri.encodeComponent(
          filePath,
        ); // encode to event-images%2F1749588617_1000088084.jpg

        return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
      }

      return url;
    }

    final String rawUrl = invitation['image'] ?? '';
    final String imageUrl = transformToFirebaseUrl(rawUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Hero(
                  tag: imageUrl,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => ImageViewPage(imageUrl: imageUrl));
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            imageUrl,
                            width: MediaQuery.of(context).size.width,
                            height: 340,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/logoY.jpg',
                                width: MediaQuery.of(context).size.width,
                                height: 340,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 36,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 0),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(width: 2, color: appTheme.appViolet),
                      ),
                      child: Text(
                        "Privé",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      // ⬅️ Allows text to wrap instead of overflowing
                      child: Text(
                        invitation["title"]!,
                        softWrap: true,
                        maxLines: null, // ⬅️ Allows multiple lines
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Post details section
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.42,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(58, 182, 113, 255),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitation["dateTime"]
                                    .toString()
                                    .split(",")
                                    .first,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Text(
                                invitation["dateTime"]
                                    .toString()
                                    .split(",")
                                    .last,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Location section with scrolling text
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(58, 182, 113, 255),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text for location with wrapping enabled
                                Text(
                                  invitation["location"]!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w200,
                                  ),
                                  softWrap: true,
                                  overflow:
                                      TextOverflow
                                          .ellipsis, // Truncate with ellipsis
                                ),
                                Text(
                                  invitation["location"]!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  softWrap: true,
                                  overflow:
                                      TextOverflow
                                          .ellipsis, // Truncate with ellipsis
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // action buttons
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      key: addToCalendar,
                      onPressed: () {
                        _addEventToCalendar(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: appTheme.appViolet, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        "Ajouter au calendrier",
                        style: TextStyle(color: appTheme.appViolet),
                      ),
                    ),

                    OutlinedButton(
                      key: seeMap,
                      onPressed: () {
                        Get.toNamed(
                          '/invitation_detail_carte',
                          arguments: invitation,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: appTheme.appViolet,
                          width: 2,
                        ), // Border color and width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ), // Button padding
                      ),
                      child: Text(
                        "Voir sur la carte",
                        style: TextStyle(
                          color: appTheme.appViolet,
                        ), // Text color
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [TitleText_1(text: "Description")]),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  invitation['description']!,
                  softWrap: true,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(height: 30),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(05),
                      decoration: BoxDecoration(
                        border: Border.all(color: appTheme.appViolet, width: 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),

                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation["location"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "Organisateur",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MainButtons(
                  key: details,
                  text: "Plus de détails",
                  onPressed:
                      () => {
                        Get.to(
                          () => AddTicketPage(
                            eventId: int.parse(invitation['id'].toString()),
                          ),
                        ),
                      },
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: buildBottomNavigation(context),
      floatingActionButton:
          _showInfoButton
              ? TutorialLauncherButton(onPressed: _showTutorial)
              : null,
      bottomNavigationBar: buildBottomNavigationInviteContact(
        context,
        invitation['id'].toString(),
        invitation['description'].toString(),
        invitation['firstTicket']?['id'].toString() ?? '0',
      ),
      // bottomNavigationBar: buildBottomNavigationInviteAccept(),
      // bottomNavigationBar: buildBottomNavigationInviteReject(),
    );
  }

  final String _name = '';
  final String _description = '';
  String? _imageUrl;
  final int _validityDays = 100;

  Future<void> _submitTicket() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Configuration de la page d'invitation en cours .... !"),
      ),
    );

    final body = {
      'event_id': invitation['id'].toString(),
      'name': invitation['title'].toString(),
      'description': _description,
      if (_imageUrl != null && _imageUrl!.isNotEmpty) 'image_url': _imageUrl,
      'quantity': 2,
      'price': 0,
      'validity_days': _validityDays,
    };

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('https://api.senjayer.com/api/v1/tickets');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        final data = resData['data']; // ✅ unwrap "data"

        print(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration réussie !')),
        );

        Get.to(
          () => ContactsInvitePage(
            eventId: int.parse(data['event_id'].toString()), // ✅ from response
            ticketId: int.parse(data['id'].toString()), // ✅ ticket ID
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        print(error);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error: Une erreur s'est produite lors de la configuration de la page d'invitation",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {});
    }
  }

  Widget buildBottomNavigation(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap:
                () => {showCustomSuccessDialog(context, "Invitation acceptée")},
            child: _buildButton(
              "Accepter",
              Colors.green.shade100,
              Colors.green.shade800,
              Icon(
                Icons.check_box_outlined,
                color: Colors.green.shade800,
                size: 20,
              ),
              null,
            ),
          ),
          InkWell(
            onTap:
                () => {
                  // showCustomErrorDialog(
                  //   context,
                  //   "Ajouté avec succès au calendrier",
                  // ),
                },
            child: _buildButton(
              "Peut être",
              Colors.orange.shade100,
              Colors.orange.shade800,
              Icon(
                Icons.timer_outlined,
                color: Colors.orange.shade800,
                size: 20,
              ),
              null,
            ),
          ),
          InkWell(
            onTap:
                () => {
                  showCustomErrorDialog(
                    context,
                    "Vous venez de refuser cette invitation",
                  ),
                },
            child: _buildButton(
              "Rejeter",
              Colors.red.shade100,
              Colors.red.shade800,
              Icon(Icons.cancel_sharp, color: Colors.red.shade800, size: 20),
              null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationInviteContact(
    BuildContext context,
    String id,
    String description,
    String ticketId,
  ) {
    void showError(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap:
                () => {
                  // Get.toNamed(
                  //   "/inviteContact",
                  //   arguments: {
                  //     "id": id.toString(),
                  //     "description": description.toString(),
                  //   },
                  // ),
                  Get.to(() => InvitationListPage(eventId: id)),
                },
            child: _buildButton(
              "Invitations",
              Colors.green.shade100,
              Colors.green.shade800,
              Icon(
                Icons.featured_play_list_sharp,
                color: Colors.green.shade800,
                size: 20,
              ),
              invited,
            ),
          ),
          InkWell(
            onTap:
                () => {
                  // Get.toNamed(
                  //   "/inviteContact",
                  //   arguments: {
                  //     "id": id.toString(),
                  //     "description": description.toString(),
                  //   },
                  // ),
                  if (ticketId == '0')
                    {_submitTicket()}
                  else
                    {
                      Get.to(
                        () => ContactsInvitePage(
                          eventId: int.parse(id),
                          ticketId: int.parse(ticketId),
                        ),
                      ),
                    },

                  // Get.to(() => InvitationListPage(eventId: id))
                },
            child: _buildButton(
              "Inviter mes contacts",
              appTheme.appViolet,
              appTheme.appWhite,
              Icon(
                Icons.add_box_outlined,
                //43, 1, 43, 100
                color: appTheme.appWhite,
                size: 20,
              ),
              inviteNew,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationInviteAccept() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
            "Invitation acceptée",
            Colors.green.shade100,
            Colors.green.shade800,
            Icon(
              Icons.check_box_outlined,
              color: Colors.green.shade800,
              size: 20,
            ),
            null,
          ),

          GestureDetector(
            onTap: () {
              Get.toNamed('/dashboard'); // Navigate to home screen
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(190, 225, 190, 231),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Image.asset("assets/home_icon.png", width: 30),
            ),
          ),

          // Create Event Button
          GestureDetector(
            onTap: () {
              // Handle event creation
              Get.toNamed('/dashboard');
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationInviteReject() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
            "Invitation refusée",
            Colors.red.shade100,
            Colors.red.shade800,
            Icon(Icons.cancel_outlined, color: Colors.red.shade800, size: 20),
            null,
          ),

          GestureDetector(
            onTap: () {
              Get.toNamed('/dashboard'); // Navigate to home screen
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(190, 225, 190, 231),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Image.asset("assets/home_icon.png", width: 30),
            ),
          ),

          // Create Event Button
          GestureDetector(
            onTap: () {
              // Handle event creation
              Get.toNamed('/dashboard');
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color bgColor,
    Color textColor,
    Icon iconic,
    GlobalKey? key,
  ) {
    return Container(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          iconic,
          SizedBox(width: 2),
          Text(
            text,

            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
