import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tophservices/main.dart';
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/user.dart'; // Import UserModel

class MapScreen extends StatefulWidget {
  final UserModel? currentUser;
  final Function(BookingLocation) onUpdateLocation;
  final bool navigateToHomePage; // New parameter

  const MapScreen({
    required this.currentUser,
    required this.onUpdateLocation,
    required this.navigateToHomePage, // Add this parameter
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LatLng selectedLocation; // Track the selected location
  Timer? _debounceTimer;
  bool _isMoving = false;
  TextEditingController streetController = TextEditingController();
  TextEditingController buildingNameController = TextEditingController();
  TextEditingController apartmentNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(
        '********************************* ${widget.currentUser!.id}*******************************');
    _locateMe();
    selectedLocation = LatLng(23.4241, 53.8478);
  }

  @override
  void dispose() {
    mapController.dispose(); // Dispose the controller if it's not null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false, // Disable zoom controls
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation,
                    zoom: 6,
                  ),
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  markers: {
                    Marker(
                      markerId: const MarkerId("selected_location"),
                      position: selectedLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen), // Custom marker color
                    ),
                  },
                ),
                _buildCenterDot(),
                Positioned(
                  bottom: 16, // Adjust the position as needed
                  right: 16, // Adjust the position as needed
                  child: ElevatedButton(
                    onPressed: _locateMe,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Color.fromRGBO(3, 173, 246, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      readOnly: true,
                      controller: streetController,
                      decoration: const InputDecoration(
                          labelText: 'Street Name',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(3, 173, 246, 1),
                              fontSize: 20),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(3, 173, 246, 1)))),
                    ),
                    TextField(
                      controller: buildingNameController,
                      decoration: const InputDecoration(
                          labelText: 'Building Name',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(3, 173, 246, 1),
                              fontSize: 14),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(3, 173, 246, 1)))),
                    ),
                    TextField(
                      controller: apartmentNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Apartment Number'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _setLocationInfoAndReturn();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(3, 173, 246, 1),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _locateMe() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // ignore: unnecessary_null_comparison
      if (mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15,
          ),
        );
      } else {
        print('Map controller is not initialized');
      }
    } catch (e) {
      print('Error locating user: $e');
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _isMoving = true;
    });

    // Reset the timer on every camera move
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
  }

  void _onCameraIdle() {
    // Start the debounce timer when the camera stops moving
    if (_isMoving) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        LatLngBounds bounds = await mapController.getVisibleRegion();
        LatLng centerLatLng = LatLng(
          (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
          (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
        );
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            centerLatLng.latitude,
            centerLatLng.longitude,
          );
          if (placemarks.isNotEmpty) {
            String streetName = placemarks.first.street ?? '';
            streetController.text = streetName;
          }
        } catch (e) {
          // Handle any errors that may occur
          print('Error: $e');
        }
        setState(() {
          selectedLocation = centerLatLng;
          _isMoving = false;
        });
      });
    }
  }

  Widget _buildCenterDot() {
    return const Center(
      child: Icon(
        Icons.circle_sharp,
        size: 8,
        color: Colors.green,
      ),
    );
  }

  void _updateLocation(LatLng selectedLocation) async {
    try {
      // Convert selectedLocation to a String representation
      String locationString =
          '${selectedLocation.latitude},${selectedLocation.longitude}';

      // Update location details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser!.id)
          .update({
        'userLocation': {
          'location': locationString,
          'buildingNumber': buildingNameController.text,
          'apartmentNumber': apartmentNumberController.text,
          // Include any other fields you want to update
        },
      });

      // Show success dialog
      _showDialog('Success', 'Location updated successfully.');
    } catch (e) {
      print('Error updating location in Firestore: $e');
      // Show error dialog
      _showDialog('Error', 'Failed to update location.');
    }
  }

  void _showDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _setLocationInfoAndReturn() async {
    // Retrieve the text values from the controllers
    String buildingName = buildingNameController.text;
    String apartmentNumber = apartmentNumberController.text;

    if (buildingName.isEmpty || apartmentNumber.isEmpty) {
      // Show an alert or message to indicate that fields are empty
      // Handle empty fields...
    } else {
      // Update location details in currentUser
      widget.currentUser!.updateBuildingNumber(buildingName);
      widget.currentUser!.updateApartmentNumber(apartmentNumber);

      // Update location in Firestore by calling the callback
      _updateLocation(selectedLocation);

      // Save updated user details
      await saveUserDetails();

      // Pass the updated location back to the parent widget
      widget.onUpdateLocation(widget.currentUser!.userLocation);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GFHomeScreen(
            index: 0,
            userId: widget.currentUser!.id,
          ),
        ),
      );
    }
  }

  Future<void> saveUserDetails() async {
    // Save updated user information to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'currentUser', jsonEncode(widget.currentUser!.toMap()));
  }
}
