import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';

class MapPickerPage extends StatefulWidget {
  @override
  _MapPickerPageState createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = LatLng(6.5244, 3.3792); // Default to Lagos
  final searchController = TextEditingController();
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace("AIzaSyBqd28Yhkv6wfyxXdR6MfY03RqlKe30E7E");
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng current = LatLng(position.latitude, position.longitude);
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(current, 15));
    setState(() {
      _selectedLocation = current;
    });
  }

  void autoCompleteSearch(String value) async {
    if (value.isNotEmpty) {
      var result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null) {
        setState(() {
          predictions = result.predictions!;
        });
      }
    } else {
      setState(() {
        predictions = [];
      });
    }
  }

  Future<void> _selectPrediction(AutocompletePrediction p) async {
    final details = await googlePlace.details.get(p.placeId!);
    final loc = details?.result?.geometry?.location;
    if (loc != null) {
      final LatLng position = LatLng(loc.lat!, loc.lng!);
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
      setState(() {
        _selectedLocation = position;
        predictions = [];
        searchController.text = details?.result?.name ?? '';
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choisir un lieu - Senjayer Priv8")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition:
                CameraPosition(target: _selectedLocation, zoom: 14.0),
            onTap: _onTap,
            markers: {
              Marker(
                markerId: MarkerId('selected_location'),
                position: _selectedLocation,
              )
            },
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Rechercher un lieu",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                    ),
                    onChanged: autoCompleteSearch,
                  ),
                ),
                if (predictions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ListView.builder(
                      itemCount: predictions.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(predictions[index].description ?? ''),
                          onTap: () => _selectPrediction(predictions[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
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
