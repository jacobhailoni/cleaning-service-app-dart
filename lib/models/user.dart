import 'package:firebase_auth/firebase_auth.dart';
import 'package:tophservices/models/booking_location_model.dart';

class UserModel {
  final String id;
  String name; // Add name field
  String email; // Add email field
  String phoneNumber; // Add phoneNumber field
  BookingLocation userLocation;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userLocation,
  });

  void updateLocation(String newLocation) {
    userLocation = BookingLocation(
        location: newLocation,
        buildingNumber: userLocation.buildingNumber,
        apartmentNumber: userLocation.apartmentNumber,
        administrativeArea: userLocation
            .administrativeArea); // Retain existing administrativeArea
  }

  void updateBuildingNumber(String newBuildingNumber) {
    userLocation = BookingLocation(
      location: userLocation.location,
      buildingNumber: newBuildingNumber,
      apartmentNumber: userLocation.apartmentNumber,
      administrativeArea:
          userLocation.administrativeArea, // Retain existing administrativeArea
    );
  }

  void updateApartmentNumber(String newApartmentNumber) {
    userLocation = BookingLocation(
      location: userLocation.location,
      buildingNumber: userLocation.buildingNumber,
      apartmentNumber: newApartmentNumber,
      administrativeArea:
          userLocation.administrativeArea, // Retain existing administrativeArea
    );
  }

  void updateAdministrativeArea(String newAdministrativeArea) {
    userLocation = BookingLocation(
      location: userLocation.location,
      buildingNumber: userLocation.buildingNumber,
      apartmentNumber: userLocation.apartmentNumber,
      administrativeArea:
          newAdministrativeArea, // Retain existing administrativeArea
    );
  }

  // Deserialize the UserModel object from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '', // Deserialize name field
      email: map['email'] ?? '', // Deserialize email field
      phoneNumber: map['phoneNumber'] ?? '', // Deserialize phoneNumber field
      userLocation: BookingLocation.fromMap(map['userLocation'] ?? {}),
    );
  }

  // Serialize the UserModel object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name, // Serialize name field
      'email': email, // Serialize email field
      'phoneNumber': phoneNumber, // Serialize phoneNumber field
      'userLocation': userLocation.toMap(),
    };
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      userLocation: BookingLocation(
        location: '',
        buildingNumber: '',
        apartmentNumber: '',
        administrativeArea: '',
      ),
    );
  }
  void updateName(String newName) {
    name = newName;
  }

  void updateMail(String newMail) {
    email = newMail;
  }

  void updatePhone(String newPhone) {
    phoneNumber = newPhone;
  }
}
