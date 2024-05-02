// import 'dart:js';

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tophservices/auth_service.dart'; // Import the AuthService class

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService;

//   AuthProvider(this._authService);

//   User? get currentUser => _authService.currentUser;

//   Future<void> signInWithPhoneNumber(
//       String phoneNumber, BuildContext context) async {
//     await _authService.signInWithPhoneNumber(context, phoneNumber);
//   }

//   Future<void> signInWithGoogle(BuildContext context) async {
//     await _authService.signInWithGoogle();
//   }

//   Future<void> signInWithFacebook(BuildContext context) async {
//     await _authService.signInWithFacebook();
//   }
// }

// class LocationDetails with ChangeNotifier {
//   String location = '';
//   String buildingName = '';
//   String apartmentNumber = '';
//   String phoneNumber = '';

//   void updateLocationDetails(String newLocation, String newBuildingName,
//       String newApartmentNumber, String newPhoneNumber) {
//     location = newLocation;
//     buildingName = newBuildingName;
//     apartmentNumber = newApartmentNumber;
//     phoneNumber = newPhoneNumber;
//     notifyListeners(); // Notify listeners (including HomePage) that the data has changed
//   }
// }
