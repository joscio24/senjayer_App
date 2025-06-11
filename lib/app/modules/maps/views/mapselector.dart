import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:senjayer/widgets/custom_loader.dart';

class MapPickerPage extends StatefulWidget {
  @override
  _MapPickerPageState createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    LatLng current = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedLocation = current;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(current, 15));
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un emplacement.')),
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    await _initializeCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choisir un lieu - Senjayer Priv8")),
      body: _selectedLocation == null
          ? Center(child: CustomLoader())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Move to current location once the map is ready
                    if (_selectedLocation != null) {
                      _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 15));
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 14.0,
                  ),
                  onTap: _onTap,
                  markers: {
                    if (_selectedLocation != null)
                      Marker(
                        markerId: MarkerId('selected_location'),
                        position: _selectedLocation!,
                      ),
                  },
                ),
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _goToCurrentLocation,
                    tooltip: 'Ma position',
                    child: Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    onPressed: _confirmLocation,
                    icon: Icon(Icons.check),
                    label: Text("Confirmer l'emplacement"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
