import 'package:flutter/material.dart';
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/MapScreen.dart';

class LocationInputField extends StatelessWidget {
  final String? buildingName;
  final String? apartmentNumber;
  final Function(BookingLocation) onUpdateLocation;
  final UserModel? currentUser;

  const LocationInputField(
      {Key? key,
      this.buildingName,
      this.apartmentNumber,
      required this.onUpdateLocation,
      required this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              onUpdateLocation: onUpdateLocation,
              navigateToHomePage: true,
              currentUser: currentUser,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on),
            const SizedBox(width: 8.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  '${buildingName ?? 'Building Name'} , ${apartmentNumber ?? 'Apartment Number'}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
