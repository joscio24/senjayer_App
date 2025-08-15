import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse('https://api.senjayer.com/api/v1/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rawList = data['data'];

        notifications.value = rawList.map<Map<String, dynamic>>((item) {
          final message = item['data']?['message'] ?? '';
          final type = item['type'] ?? '';
          final isRead = item['read_at'] != null;

          return {
            'id': item['id'],
            'title': type.split('\\').last, // Show class name like InvoicePaid
            'body': message,
            'isRead': isRead,
            'created_at': item['created_at'],
          };
        }).toList();
      } else {
        print("Erreur: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors du chargement des notifications: $e");
    }
  }
}
