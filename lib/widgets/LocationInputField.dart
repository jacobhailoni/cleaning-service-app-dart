import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/MapScreen.dart';

class LocationInputField extends StatelessWidget {
  final UserModel? currentUser;
  final Function(BookingLocation) onUpdateLocation;

  const LocationInputField({
    Key? key,
    required this.currentUser,
    required this.onUpdateLocation,
  }) : super(key: key);

  Future<Map<String, String?>> getLocationDetails() async {
    if (currentUser == null || currentUser!.id.isEmpty) {
      return {
        'location': null,
        'buildingName': null,
        'apartmentNumber': null,
      };
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.id)
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data()!;
        Map<String, dynamic>? userLocationData = userData['userLocation'];

        if (userLocationData != null) {
          String? location = userLocationData['location'];
          String? buildingName = userLocationData['buildingNumber'];
          String? apartmentNumber = userLocationData['apartmentNumber'];

          return {
            'location': location,
            'buildingName': buildingName,
            'apartmentNumber': apartmentNumber,
          };
        }
      }
    } catch (e) {
      print('Error getting user location details: $e');
    }

    return {
      'location': null,
      'buildingName': null,
      'apartmentNumber': null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              currentUser: currentUser,
              onUpdateLocation: onUpdateLocation,
              navigateToHomePage: true,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on),
            SizedBox(width: 8.0),
            Expanded(
              // Added Expanded to allow the text field to take up remaining space
              child: FutureBuilder<Map<String, String?>>(
                future: getLocationDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        // Wrap with SingleChildScrollView
                        scrollDirection: Axis
                            .horizontal, // Set scroll direction to horizontal
                        child: Text(
                          '${snapshot.data!['buildingName']} , ${snapshot.data!['apartmentNumber']}',
                          style: TextStyle(fontSize: 15),
                        ),
                      );
                    } else {
                      return Text('Location not available');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
