import 'package:flutter/material.dart';
import 'package:senjayer/app/core/theme.dart';

class InvitationCard extends StatelessWidget {
  final int? id;
  final int? categoryId;
  final int? userId;
  final String title;
  final String description;
  final String location;
  final String evimage;
  final String dateTime;
  final String endDate;
  final int? nbPlace;
  final int? status;
  final bool? isPrivate;
  final bool? hasTicket;
  final bool? ticketAvailable;
  final String? startTicket;
  final String? endTicket;
  final String? addressLongitude;
  final String? addressLatitude;

  const InvitationCard({super.key, 
    this.id,
    this.categoryId,
    this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.evimage,
    required this.dateTime,
    required this.endDate,
    this.nbPlace,
    this.status,
    this.isPrivate,
    this.hasTicket,
    this.ticketAvailable,
    this.startTicket,
    this.endTicket,
    this.addressLongitude,
    this.addressLatitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      // padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image:
                  evimage.isNotEmpty &&
                          evimage.contains('https')
                      ? NetworkImage(evimage) as ImageProvider
                      : AssetImage('assets/logo.png'),
              width: 100,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),

          // SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),

              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 239, 239),
                border: Border.all(width: 1, color: Colors.black38),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: appTheme.appViolet,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: appTheme.appViolet,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        dateTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(
                        "Accepter",
                        Colors.green.shade100,
                        Colors.green.shade800,
                      ),
                      _buildButton(
                        "Peut être",
                        Colors.orange.shade100,
                        Colors.orange.shade800,
                      ),
                      _buildButton(
                        "Rejeter",
                        Colors.red.shade100,
                        Colors.red.shade800,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final int? id;
  final int? categoryId;
  final int? userId;
  final String title;
  final String description;
  final String location;
  final String evimage;
  final String dateTime;
  final String endDate;
  final int? nbPlace;
  final int? status;
  final bool? isPrivate;
  final bool? hasTicket;
  final bool? ticketAvailable;
  final String? startTicket;
  final String? endTicket;
  final String? addressLongitude;
  final String? addressLatitude;

  const EventCard({super.key, 
    this.id,
    this.categoryId,
    this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.evimage,
    required this.dateTime,
    required this.endDate,
    this.nbPlace,
    this.status,
    this.isPrivate,
    this.hasTicket,
    this.ticketAvailable,
    this.startTicket,
    this.endTicket,
    this.addressLongitude,
    this.addressLatitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      // padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image:
                  evimage.isNotEmpty &&
                          evimage.contains('https')
                      ? NetworkImage(evimage) as ImageProvider
                      : AssetImage('assets/logoY.jpg'),
              width: 100,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),

          // SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              height: 110,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 239, 239),
                border: Border.all(width: 1, color: Colors.black38),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: appTheme.appViolet,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: appTheme.appViolet,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        dateTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
