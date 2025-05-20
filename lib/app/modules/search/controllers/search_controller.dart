import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSearchController extends GetxController {
  var selectedFilters = <String>[].obs;
  var selectedDate = Rx<DateTime?>(null);  // Store the selected date

  final List<String> availableFilters = [
    'Événements',
    'Invitations reçues',
    'Date', // Add the new "Date" filter option
  ];

  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
  }

  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }
}
