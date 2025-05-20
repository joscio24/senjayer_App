import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import '../../../../widgets/custom_cards.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_data_controller.dart';
import 'package:intl/intl.dart'; // For formatting and parsing dates

class SearchPage extends StatelessWidget {
  final AppSearchController controller = Get.put(AppSearchController());
  final SearchDataController dataController = Get.put(SearchDataController());
  final searchText = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Rechercher...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: appTheme.appWhite),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) => searchText.value = value,
        ),
        backgroundColor: appTheme.appViolet,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.appWhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          _buildFilterChips(context, controller),
          Divider(),
          Expanded(
            child: Obx(() {
              final search = searchText.value.trim().toLowerCase();
              final filters = controller.selectedFilters;
              final selectedDate = controller.selectedDate.value;

              final results = <Map<String, dynamic>>[];

              bool matchSearch(Map<String, dynamic> e) {
                final title = e["title"]?.toLowerCase() ?? "";
                final desc = e["description"]?.toLowerCase() ?? "";
                final location = e["location"]?.toLowerCase() ?? "";
                final dateStr = e["dateTime"] ?? "";
                final matchText = title.contains(search) ||
                    desc.contains(search) ||
                    location.contains(search);

                final matchDate = selectedDate != null &&
                    _isSameDate(dateStr, selectedDate);

                // If "Date" is selected, include date match
                if (filters.contains("Date")) {
                  return matchText && matchDate;
                }
                return matchText;
              }

              if (filters.contains("Invitations") && search.isNotEmpty) {
                results.addAll(dataController.invitations.where(matchSearch));
              }

              if (filters.contains("Événements") && search.isNotEmpty) {
                results.addAll(dataController.events.where(matchSearch));
              }

              if (search.isEmpty && !filters.contains("Date")) {
                return Center(child: Text("Tapez pour rechercher..."));
              }

              if (results.isEmpty) {
                return Center(child: Text("Aucun résultat trouvé."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: results.length,
                itemBuilder: (_, index) {
                  final item = results[index];
                  return _buildResultCard(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, AppSearchController controller) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Wrap(
          spacing: 10,
          alignment: WrapAlignment.start,
          runSpacing: 1,
          children: controller.availableFilters.map((filter) {
            final isSelected = controller.selectedFilters.contains(filter);
            return FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) async {
                controller.toggleFilter(filter);

                if (filter == "Date" && !isSelected) {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.setSelectedDate(picked);
                  }
                } else if (filter == "Date" && isSelected) {
                  controller.setSelectedDate(null);
                }
              },
              selectedColor: appTheme.appViolet,
              checkmarkColor: appTheme.appWhite,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? appTheme.appWhite : appTheme.appSlightViolet,
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildResultCard(Map<String, dynamic> event) {
    return InkWell(
      onTap: () {
        Get.toNamed('/user_events_details', arguments: event);
      },
      child: EventCard(
        evimage: event["image"] ?? "assets/default.png",
        title: event["title"] ?? "No Title",
        location: event["location"] ?? "Unknown Location",
        dateTime: event["dateTime"] ?? "Unknown Date",
        description: event["description"] ?? "No Description",
        endDate: event["endDate"] ?? "Unknown End Date",
      ),
    );
  }

  bool _isSameDate(String dateStr, DateTime selectedDate) {
    try {
      final parsed = DateTime.parse(dateStr);
      return parsed.year == selectedDate.year &&
          parsed.month == selectedDate.month &&
          parsed.day == selectedDate.day;
    } catch (_) {
      return false;
    }
  }
}
