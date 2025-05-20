import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../api/api_services.dart';

class SearchDataController extends GetxController {
  var invitations = <Map<String, dynamic>>[].obs;
  var events = <Map<String, dynamic>>[].obs;
  var localInviteCount = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSearchData();
  }

  void loadSearchData() async {
    isLoading.value = true;

    await Future.wait([
      _loadUserEvents(),
      _loadUserEventsInvited(),
      _loadTotalInvitations()
    ]);

    isLoading.value = false;
  }

  var selectedDate = Rx<DateTime?>(null);

  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  Future<void> _loadUserEventsInvited() async {
    ApiService apiService = ApiService();
    var eventsResponse = await apiService.getEventsData();

    if (eventsResponse == null || !(eventsResponse["success"] as bool)) {
      print("Failed to load invited events: ${eventsResponse?["message"]}");
      return;
    }

    List eventList = (eventsResponse["events"] is List)
        ? eventsResponse["events"]
        : (eventsResponse["events"]["data"] ?? []);

    List filtered = eventList.where((e) => e["private"] == 1).toList();

    invitations.assignAll(filtered.map<Map<String, dynamic>>((event) => {
      "image": event["image_url"] ?? "assets/default.png",
      "title": event["name"] ?? "No Title",
      "location": event["event_address"] ?? "Unknown Location",
      "dateTime": _formatDate(event["start_date"], event["end_date"]),
      "description": event["description"] ?? "",
      "status": event["status"]?.toString() ?? "",
      "nbPlace": event["nb_place"]?.toString() ?? "0",
      "hasTicket": event["has_ticket"]?.toString() ?? "false",
      "ticketAvailable": event["ticket_available"]?.toString() ?? "false",
    }).toList());
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

  Future<void> _loadUserEvents() async {
    ApiService apiService = ApiService();
    var eventsResponse = await apiService.getUsersEventsData();

    if (eventsResponse == null || !(eventsResponse["success"] as bool)) {
      print("Failed to load created events: ${eventsResponse?["message"]}");
      return;
    }

    List eventList = (eventsResponse["events"] is List)
        ? eventsResponse["events"]
        : (eventsResponse["events"]["data"] ?? []);

    List filtered = eventList.where((e) => e["private"] == 1).toList();

    events.assignAll(filtered.map<Map<String, dynamic>>((event) => {
      "image": event["image_url"] ?? "assets/default.png",
      "title": event["name"] ?? "No Title",
      "location": event["event_address"] ?? "Unknown Location",
      "dateTime": _formatDate(event["start_date"], event["end_date"]),
      "description": event["description"] ?? "",
      "status": event["status"]?.toString() ?? "",
      "nbPlace": event["nb_place"]?.toString() ?? "0",
      "hasTicket": event["has_ticket"]?.toString() ?? "false",
      "ticketAvailable": event["ticket_available"]?.toString() ?? "false",
    }).toList());
  }

  Future<void> _loadTotalInvitations() async {
    int count = await _getTotalInvitationCount();
    localInviteCount.value = count;
  }

  Future<int> _getTotalInvitationCount() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts_event.db');
    final database = await openDatabase(path);

    final List<Map<String, dynamic>> totalInvitations = await database.rawQuery('''
      SELECT COUNT(*) as total_invites
      FROM invitations
    ''');

    return totalInvitations.isNotEmpty ? totalInvitations.first['total_invites'] ?? 0 : 0;
  }


}
