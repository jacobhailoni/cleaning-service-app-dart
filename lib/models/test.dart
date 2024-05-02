import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewMapScreen extends StatefulWidget {
  @override
  _NewMapScreenState createState() => _NewMapScreenState();
}

class _NewMapScreenState extends State<NewMapScreen> {
  late GoogleMapController mapController;
  late LatLng selectedLocation; // Track the selected location
  Timer? _debounceTimer;
  bool _isMoving = false;
  TextEditingController buildingNameController = TextEditingController();
  TextEditingController apartmentNumberController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedLocation =
        LatLng(23.4241, 53.8478); // Initial location (UAE coordinates)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Map Screen'),
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
                      markerId: MarkerId("selected_location"),
                      position: selectedLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure), // Custom marker color
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
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Icon(
                      Icons.my_location,
                      color: Color.fromRGBO(3, 173, 246, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: buildingNameController,
                  decoration: InputDecoration(labelText: 'Building Name'),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: apartmentNumberController,
                  decoration: InputDecoration(labelText: 'Apartment Number'),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(3, 173, 246, 1))),
                  onPressed: () {
                    // Handle save button press
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
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
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
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
      _debounceTimer = Timer(Duration(milliseconds: 500), () async {
        LatLngBounds bounds = await mapController.getVisibleRegion();
        LatLng centerLatLng = LatLng(
          (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
          (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
        );
        setState(() {
          selectedLocation = centerLatLng;
          _isMoving = false;
        });
      });
    }
  }

  Widget _buildCenterDot() {
    return Center(
      child: Icon(
        Icons.circle_sharp,
        size: 8,
        color: Colors.red,
      ),
    );
  }
}
