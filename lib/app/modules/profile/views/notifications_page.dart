import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';

import '../controllers/notification_controller.dart';

class NotificationsPage extends StatelessWidget {
  final NotificationController _controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    _controller.fetchNotifications(); // Assumes this populates the list of Map<String, dynamic>

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        final notifications = _controller.notifications;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];

            return NotificationCard(
              title: notification['title'] ?? 'No Title',
              body: notification['body'] ?? '',
              isRead: notification['isRead'] ?? false,
              onTap: () {
                // Optionally mark as read or navigate
              },
            );
          },
        );
      }),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    required this.title,
    required this.body,
    required this.isRead,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0EEFF), // Purple for unread
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: isRead ? appTheme.appViolet : appTheme.appSlightViolet,
          child: const Icon(Icons.notifications, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            const SizedBox(height: 4),
            const Text(
              'a few seconds ago', // Placeholder — you can format actual time if needed
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
