import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_addtocalendar.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_cards.dart';
import 'package:senjayer/widgets/custom_reject_dialog.dart';
import 'package:senjayer/widgets/custom_success_dialog.dart';
import 'package:senjayer/widgets/custom_textfield.dart';
import 'package:intl/intl.dart';

class InvitationDetails extends StatelessWidget {
  // final email_controller = TextEditingController();

  // String getFormattedDate() {
  //   DateTime now = DateTime.now();
  //   // Format the date to the required format
  //   String dayOfWeek = DateFormat(
  //     'EEEE',
  //   ).format(now); // EEEE returns the full name of the day
  //   String day = DateFormat('d').format(now); // d returns the day of the month
  //   String month = DateFormat(
  //     'MMMM',
  //   ).format(now); // MMMM returns the full name of the month
  //   String year = DateFormat('yyyy').format(now); // yyyy returns the year

  //   return '$dayOfWeek, $day $month $year';
  // }

  // Format date from API (e.g., "2024-04-01T17:00:00.000000Z" → "01 April 2024, 17:00")
  // String _formatDate(String? dateTimeStr) {
  //   if (dateTimeStr == null) return "Unknown Date";

  //   DateTime dateTime = DateTime.parse(dateTimeStr);
  //   return "${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  // }

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

   InvitationDetails({super.key});

  // String formattedDate = getFormattedDate();
  // List<String> dateParts = formattedDate.split(", ");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  invitation['image']!,
                  width: MediaQuery.of(context).size.width * 1,
                  height: 300,
                  fit: BoxFit.cover,
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
                    Text(
                      invitation["title"]!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
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
                    // post details
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
                            child: Icon(Icons.location_on, color: Colors.black),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitation["location"]!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Text(
                                invitation["location"]!,
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
                      onPressed: () {
                        // Get.toNamed('/detailsPage');
                        showCustomAddSuccessDialog(
                          context,
                          "Ajouté avec succès au calendrier",
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
                        "Ajouter au calendrier",
                        style: TextStyle(
                          color: appTheme.appViolet,
                        ), // Text color
                      ),
                    ),
                    OutlinedButton(
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
                          invitation['image']!,
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
                          "BIIC",
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
                  text: "Plus de détails",
                  onPressed: () => {},
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: buildBottomNavigation(context),
      bottomNavigationBar: buildBottomNavigationInviteAccept(),
      // bottomNavigationBar: buildBottomNavigationInviteReject(),
    );
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
            Icon(Icons.timer_outlined, color: Colors.orange.shade800, size: 20),
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

Widget _buildButton(String text, Color bgColor, Color textColor, Icon iconic) {
  return Container(
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
