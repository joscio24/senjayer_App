import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  _InvitationDetailsPageState createState() => _InvitationDetailsPageState();
}

class _InvitationDetailsPageState extends State<CartView> {
  final Map<String, dynamic> invitation = Get.arguments;

  late GoogleMapController mapController;
  // Example: San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // final LatLng _location = LatLng(6.3755361, 2.4117988);

    final LatLng location = LatLng(
      double.parse(invitation['latitude']!),
      double.parse(invitation['longitude']!),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Maps Widget
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.65, // Adjust height as needed
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 14.0,
                ),
                mapType: MapType.normal,
                liteModeEnabled: false,
                markers: {
                  Marker(
                    markerId: MarkerId('event_location'),
                    position: location,
                    infoWindow: InfoWindow(title: 'Event Location'),
                  ),
                },
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                invitation['image']!,
                width: MediaQuery.of(context).size.width,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 10,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.appViolet,
                side: BorderSide(
                  color: appTheme.appViolet,
                  width: 2,
                ), // Border color and width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ), // Button padding
              ),
              child: Text(
                "Fermer la carte",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                ), // Text color
              ),
            ),
          ),
          // SizedBox(height: 10),
        ],
      ),
    );
  }
}
