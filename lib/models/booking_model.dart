import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tophservices/models/booking_location_model.dart';

class Booking {
  final String id;
  final String userId;
  final String serviceID;
  final BookingLocation location;
  final String date;
  final TimeOfDay time;
  final double hours;
  final int maidsCount;
  final bool withMaterials;
  final double totalPrice;

  Booking({
    required this.id,
    required this.userId,
    required this.serviceID,
    required this.location,
    required this.date,
    required this.time,
    required this.hours,
    required this.maidsCount,
    required this.withMaterials,
    required this.totalPrice,
  });

// Define a function to convert map to TimeOfDay

// Modify the factory method to use the function
  factory Booking.fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    TimeOfDay mapToTimeOfDay(Map<String, dynamic> timeMap) {
      return TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);
    }

    // Extract location data and create a BookingLocation object
    Map<String, dynamic> locationData = data['location'] ?? {};
    BookingLocation location = BookingLocation(
      location: locationData['location'] ?? '',
      buildingNumber: locationData['buildingNumber'] ?? '',
      apartmentNumber: locationData['apartmentNumber'] ?? '',
      administrativeArea: locationData['administrativeArea'] ?? '',
    );

    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      serviceID: data['serviceId'] ?? '',
      location: location,
      date: data['date'] ?? '',
      time: mapToTimeOfDay(data['time']), // Use the function to convert
      hours: (data['hours'] ?? 0).toDouble(),
      maidsCount: data['maidsCount'] ?? 0,
      withMaterials: data['withMaterials'] ?? false,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }
}
