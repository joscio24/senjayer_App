import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final Map<String, dynamic> invitation = Get.arguments;
  late GoogleMapController _mapController;

  // Transform GCS to Firebase Storage URL
  String transformToFirebaseUrl(String url) {
    if (url.startsWith('https://storage.cloud.google.com/')) {
      final uri = Uri.parse(url);
      final bucket = uri.pathSegments.first;
      final filePath = uri.pathSegments.skip(1).join('/');
      final encodedPath = Uri.encodeComponent(filePath);
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
    }
    return url;
  }

  double parseLatitude(dynamic value) {
    double? val = double.tryParse(value?.toString() ?? '');
    if (val == null) {
      print('Invalid latitude value: $value. Using 0.');
      return 0.0;
    }
    // Convert microdegrees to degrees
    val = val / 1000000;

    if (val < -90 || val > 90) {
      print('Latitude out of range after conversion: $val. Using 0.');
      return 0.0;
    }
    return val;
  }

  double parseLongitude(dynamic value) {
    double? val = double.tryParse(value?.toString() ?? '');
    if (val == null) {
      print('Invalid longitude value: $value. Using 0.');
      return 0.0;
    }
    // Convert microdegrees to degrees
    val = val / 1000000;

    if (val < -180 || val > 180) {
      print('Longitude out of range after conversion: $val. Using 0.');
      return 0.0;
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    final double latitude =
        double.tryParse(invitation['latitude']) ?? 0.0;
    final double longitude =
        double.tryParse(invitation['longitude']) ?? 0.0;
    final LatLng location = LatLng(latitude, longitude);

    print('invitation: $invitation'); 

    final String rawUrl = invitation['image'] ?? '';
    final String imageUrl = transformToFirebaseUrl(rawUrl);

    print('Raw latitude: ${invitation['latitude']}');
    print('Raw longitude: ${invitation['longitude']}');
    print("Location:$location");

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 20.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('event_location'),
                  position: location,
                  infoWindow: InfoWindow(title: invitation['location'].toString()),
                ),
              },
              mapType: MapType.normal,
              liteModeEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
            ),
          ),

          // Event image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),

          // Close button
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.appViolet,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(Icons.close, color: Colors.white),
              label: const Text(
                "Fermer la carte",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
