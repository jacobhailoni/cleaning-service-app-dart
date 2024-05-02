import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tophservices/models/booking_location_model.dart';

class LocationFetchingTextField extends StatelessWidget {
  final String userId; // Add user ID as a parameter

  const LocationFetchingTextField(
      {super.key, required this.userId}); // Constructor to accept user ID

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: getLocationDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Map<String, String?> data = snapshot.data!;
          return Column(
            children: [
              // Location details text field
              Center(
                child: Text(
                  '${data['buildingName']}  ||  ${data['apartmentNumber']}',
                  style: const TextStyle(color: Colors.white),
                ),
              )

              // TextField(
              //   readOnly: true,
              //   controller: TextEditingController(
              //     text:
              //         '${data['location']}, ${data['buildingName']}, ${data['apartmentNumber']}',
              //   ),
              //   decoration: InputDecoration(
              //     labelText: 'Location',
              //     suffixIcon: IconButton(
              //         icon: Icon(Icons.edit),
              //         onPressed: () {
              //           // Navigate to the map page for editing location details
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => MapScreen(
              //                 onLocationSelected: (locationDetails) async {
              //                   // Save updated location details to local storage
              //                   await saveLocationDetails(
              //                       locationDetails, userId);
              //                 },
              //                 userId: userId,
              //               ),
              //             ),
              //           ).then((result) {
              //             if (result != null) {
              //               // Handle result if needed
              //             }
              //           });
              //         }),
              //   ),
              // ),
              // Phone number text field
              // TextField(
              //   controller: phoneNumberController,
              //   decoration: InputDecoration(
              //     labelText: 'Phone Number',
              //   ),
              // ),
            ],
          );
        }
      },
    );
  }

  Future<Map<String, String?>> saveLocationDetails(
      BookingLocation locationDetails, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('$userId-location', locationDetails.location);
    await prefs.setString(
        '$userId-buildingName', locationDetails.buildingNumber);
    await prefs.setString(
        '$userId-apartmentNumber', locationDetails.apartmentNumber);

    // Return the updated location details
    return {
      'location': locationDetails.location,
      'buildingName': locationDetails.buildingNumber,
      'apartmentNumber': locationDetails.apartmentNumber,
    };
  }

  Future<Map<String, String?>> getLocationDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? buildingName = prefs.getString('buildingName');
    String? apartmentNumber = prefs.getString('apartmentNumber');
    String? phoneNumber = prefs.getString('phoneNumber');

    return {
      'location': location,
      'buildingName': buildingName,
      'apartmentNumber': apartmentNumber,
      'phoneNumber': phoneNumber,
    };
  }
}

TextEditingController phoneNumberController = TextEditingController();
