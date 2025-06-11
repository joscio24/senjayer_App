import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For GetX state management
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Map
import 'package:intl/intl.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/app/modules/maps/views/mapselector.dart';
import 'package:senjayer/app/services/loaderServices.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
// For shared preferences

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventView> {
  // Controllers for form fields
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final nbPlaceController = TextEditingController();

  // Variables for form data
  String? selectedCategory;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? startTicket;
  DateTime? endTicket;
  File? imageUrl;
  double? longitude;
  double? latitude;
  List<String> guestList = [];
  int userId = 0; // This will come from SharedPreferences

  // Category list for dropdown
  // List<String> categories = [];
  List<Map<String, dynamic>> categories = [];

  int? selectedCategoryId;
  // Google Maps location state
  late GoogleMapController _mapController;
  final LatLng _initialLocation = LatLng(
    37.7749,
    -122.4194,
  ); // Default to San Francisco
  late LatLng _location = _initialLocation; // Initial marker position

  // Initialize the picker and location services
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _getUserId();
  }

  Future<void> _selectDate(BuildContext context, String dateType) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      // locale: Locale('fr', 'FR'), // Set locale to French
    );

    // if (pickedDate != null && pickedDate != DateTime.now()) {
    //   setState(() {
    //     if (dateType == 'startDate') {
    //       startDate = pickedDate;
    //     } else if (dateType == 'endDate') {
    //       endDate = pickedDate;
    //     } else if (dateType == 'startTicket') {
    //       startTicket = pickedDate;
    //     } else if (dateType == 'endTicket') {
    //       endTicket = pickedDate;
    //     }
    //   });
    // }

    if (pickedDate != null) {
      // Step 2: Pick a Time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine Date & Time
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Update the state
        setState(() {
          switch (dateType) {
            case 'startDate':
              startDate = fullDateTime;
              break;
            case 'endDate':
              endDate = fullDateTime;
              break;
            case 'startTicket':
              startTicket = fullDateTime;
              break;
            case 'endTicket':
              endTicket = fullDateTime;
              break;
          }
        });
      }
    }
  }

  String _formatDate(DateTime date) {
  // format date as you want, for example:
  return DateFormat('dd/MM/yyyy').format(date);
}

  // Fetch categories from the server
  void _loadCategories() async {
    ApiService apiService = ApiService();
    var categoryResponse = await apiService.getEventsCategories();

    if (categoryResponse == null || !(categoryResponse["success"] as bool)) {
      print("Failed to load categories: ${categoryResponse?["message"]}");
      return;
    }

    // Extract the list of categories safely
    List categoryList =
        (categoryResponse["events"] is List)
            ? categoryResponse["events"]
            : (categoryResponse["categories"]["data"] ?? []);

    // Store both ID & Name
    setState(() {
      categories =
          categoryList
              .map<Map<String, dynamic>>(
                (category) => {"id": category["id"], "name": category["name"]},
              )
              .toList();
    });
  }

  void _handleEventCreation(BuildContext context) async {
    ApiService apiService = ApiService();

    // Ensure required fields are not empty
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedCategoryId == null ||
        startDate == null ||
        endDate == null ||
        startTicket == null ||
        endTicket == null ||
        imageUrl == null || // Ensure image file is selected
        longitude == null ||
        latitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    GetLoaderAction().showLoader();

    // Send request to create event
    var result = await apiService.createEvent(
      name: nameController.text,
      description: descriptionController.text,
      eventAddress: addressController.text,
      addressLongitude: longitude!,
      addressLatitude: latitude!,
      imageUrl: imageUrl!, // Pass the file instead of a string
      categoryId: selectedCategoryId.toString(),
      private: 1, // Set default private value (adjust as needed)
      userId: userId, // Use stored user ID
      startDate: startDate!.toIso8601String(),
      endDate: endDate!.toIso8601String(),
      nbPlace: int.tryParse(nbPlaceController.text) ?? 0,
      startTicket: startTicket!.toIso8601String(),
      endTicket: endTicket!.toIso8601String(),
      status: 1, // Default status
      guest: guestList,
    );

    // Handle response
    if (result?["success"]) {
      GetLoaderAction().closeLoader();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Événement créé avec succès!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to event list or dashboard
      Get.toNamed("/user_events");
    } else {
      GetLoaderAction().closeLoader();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur: ${result?["error_details"]["message"] ?? 'Problème inconnu'}",
          ),
          backgroundColor: Colors.red,
        ),
      );
      print("Event creation failed: ${result?["error_details"]}");
    }
  }

  // Get user ID from SharedPreferences
  void _getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the stored string
    String? userString = prefs.getString("user");

    if (userString != null) {
      // Decode JSON into a Map
      Map<String, dynamic> userData = jsonDecode(userString);

      setState(() {
        userId = userData["id"] ?? 0; // Get 'id', default to 0 if null
      });
    } else {
      setState(() {
        userId = 0; // Default value if "user" does not exist
      });
    }
  }

  // Function to handle image selection

  void _pickImage() async {
    // Request permissions
    // var status = await Permission.storage.request();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text(
                  'Select Image from Gallery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  // Pick image from gallery
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      imageUrl = File(
                        pickedFile.path,
                      ); // Store the selected image path
                    });
                  }
                  Navigator.pop(context); // Close bottom sheet after selection
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet on cancel
                },
              ),
            ],
          ),
        );
      },
    );

    // if (status.isGranted) {
    //   // Show the bottom sheet with options
    //   } else {
    //   // Handle permission denied case
    //   print("Permission denied!");
    // }
  }

  LatLng? selectedLocation;
  // Function to handle location selection on the map
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Function to handle tapping on the map to select the location
  void _openMapSelector() async {
    LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerPage()),
    );

    selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerPage()),
    );

    if (pickedLocation != null) {
      setState(() {
        latitude = pickedLocation.latitude;
        longitude = pickedLocation.longitude;
      });

      print("Lat: $latitude, Lng: $longitude");
    }
  }

  // Function to handle form submission
  void _submitForm() {
    final eventData = {
      "name": nameController.text,
      "description": descriptionController.text,
      "event_address": addressController.text,
      "address_longitude": longitude ?? 0,
      "address_latitude": latitude ?? 0,
      "image_url": imageUrl ?? "",
      "category_id": selectedCategory ?? 1,
      "private": 0,
      "user_id": userId,
      "start_date": startDate?.toIso8601String() ?? "",
      "end_date": endDate?.toIso8601String() ?? "",
      "nb_place": int.tryParse(nbPlaceController.text) ?? 0,
      "start_ticket": startTicket?.toIso8601String() ?? "",
      "end_ticket": endTicket?.toIso8601String() ?? "",
      "status": 0,
      "guest": guestList,
    };
    print(eventData);
    // Send data to your API endpoint or save the data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un évenement')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Name Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("Image de l'évenement (Cliquez pour modifier)"),
                  ],
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 290,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black26),

                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child:
                        imageUrl == null
                            ? Image.asset(
                              'assets/logo.png',
                              height: 150,
                              fit: BoxFit.cover,
                              alignment:
                                  Alignment
                                      .topCenter, // 👈 ensures top part is shown
                            )
                            : Image.file(
                              File(imageUrl!.path),
                              height: 150,
                              fit: BoxFit.cover,
                              alignment:
                                  Alignment
                                      .topCenter, // 👈 crop starts from top
                            ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              SizedBox(height: 16),
              CustomTextField(
                labelText: "Nom de l'évenement",
                controller: nameController,
                hintText: 'Concert hola worlds',
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 109, 109, 109),
                    width: 1,
                  ), // Border color and width
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                child: DropdownButton<int>(
                  value: selectedCategoryId,
                  onChanged: (int? newCategoryId) {
                    print("Selected Category id: $selectedCategoryId");
                    setState(() {
                      selectedCategoryId = newCategoryId;
                    });
                  },
                  hint: Text(
                    'Sélectionnez une catégorie',
                    style: TextStyle(fontSize: 18),
                  ),
                  isExpanded: true,
                  underline: SizedBox(),
                  items:
                      categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category["id"], // Store the ID as value
                          child: Text(
                            category["name"], // Display the category name
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }).toList(),
                ),
              ),

              SizedBox(height: 16),
              // Description Input
              CustomTextField(
                labelText: 'Description',
                controller: descriptionController,
                hintText: 'Enter event description',
              ),
              SizedBox(height: 16),

              // Address Input
              CustomTextField(
                labelText: "Nom du lieu de l'évenement",
                controller: addressController,
                hintText: 'Enter event address',
              ),
              SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDatePickerField(
                    context,
                    label: "Date de début de l'événement :",
                    selectedDate: startDate,
                    onTap: () => _selectDate(context, 'startDate'),
                  ),
                  SizedBox(height: 20),
                  _buildDatePickerField(
                    context,
                    label: "Date de fin de l'événement :",
                    selectedDate: endDate,
                    onTap: () => _selectDate(context, 'endDate'),
                  ),
                  SizedBox(height: 20),
                  _buildDatePickerField(
                    context,
                    label: "Début des ventes de billets :",
                    selectedDate: startTicket,
                    onTap: () => _selectDate(context, 'startTicket'),
                  ),
                  SizedBox(height: 20),
                  _buildDatePickerField(
                    context,
                    label: "Fin des ventes de billets :",
                    selectedDate: endTicket,
                    onTap: () => _selectDate(context, 'endTicket'),
                  ),
                  SizedBox(height: 20),
                ],
              ),

              SizedBox(height: 20),
              CustomTextField(
                labelText: 'Nombre de place',
                controller: nbPlaceController,
                hintText: 'nombre de place pour cet évenement',
                inputType: TextInputType.number,
              ),
              SizedBox(height: 16),

              SizedBox(height: 16),

              // Category Dropdown
              Row(children: [Text("Lieu de l'évenement")]),

              // Google Map for location selection
              // SizedBox(
              //   height: 300,
              //   child: GoogleMap(
              //     onMapCreated: _onMapCreated,
              //     initialCameraPosition: CameraPosition(
              //       target: _initialLocation,
              //       zoom: 14.0,
              //     ),
              //     mapType: MapType.normal,
              //     liteModeEnabled: false,
              //     markers: {
              //       Marker(
              //         markerId: MarkerId('event_location'),
              //         position: _location,
              //         infoWindow: InfoWindow(title: 'Event Location'),
              //       ),
              //     },
              //     onTap: _onTap, // Allow user to select location on map
              //   ),
              // ),
              _buildLocationButton(),

              GestureDetector(
                onTap: _openMapSelector,
                child: SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        selectedLocation != null
                            ? GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: selectedLocation!,
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('selected_location'),
                                  position: selectedLocation!,
                                ),
                              },
                              onMapCreated: (_) {},
                              myLocationEnabled: false,
                              zoomControlsEnabled: false,
                              liteModeEnabled:
                                  true, // Important for performance
                            )
                            : Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  "Aucun emplacement sélectionné.\nAppuyez pour choisir.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              SizedBox(height: 16),
              MainButtons(
                text: "Créer l'évenement",
                onPressed: () => {_handleEventCreation(context)},
              ),

              SizedBox(height: 16),
              // Submit Button
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget function to avoid code repetition
  Widget _buildDatePickerField(
    BuildContext context, {
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.grey[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(
                          selectedDate,
                        ) // Pass the non-nullable DateTime here
                        : 'Sélectionner',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          selectedDate != null
                              ? Colors.black87
                              : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return InkWell(
      onTap: _openMapSelector,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_pin, size: 43, color: Colors.blue),
            const SizedBox(width: 08),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choisir un emplacement sur la carte",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (latitude != null && longitude != null)
                    Text(
                      "Lat: $latitude, Lng: $longitude",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
