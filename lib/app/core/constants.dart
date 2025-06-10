

import 'package:shared_preferences/shared_preferences.dart';

class AppCheck {
  // Get event limit
  static Future<int> getEventLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('event_limit') ?? 0;
  }

  // Check if user has a premium subscription
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_paid') ?? false;
  }

  // Optional: get package ID
  static Future<int?> getPackageId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('package_id');
  }
}
