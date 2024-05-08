import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/user.dart';

class HomePageBloc {
  final String userId;
  late UserModel? currentUser;

  HomePageBloc(this.userId);

  Future<void> loadUserData() async {
    currentUser = UserModel(
      id: userId,
      name: '',
      email: '',
      phoneNumber: '',
      userLocation: BookingLocation(
        location: '',
        buildingNumber: '',
        apartmentNumber: '',
        administrativeArea: '',
      ),
    );

    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userDataMap = userSnapshot.data()!;
        currentUser = UserModel.fromMap(userDataMap);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> saveUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(currentUser?.toMap()));
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<List<DocumentSnapshot>> fetchServices() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('services').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  void updateLocationInfo(BookingLocation newLocation) {
    if (currentUser != null) {
      currentUser!.userLocation = newLocation;
    }
  }
}
