import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/booking_model.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

Future<DocumentSnapshot> fetchService(String serviceId) async {
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('services')
        .doc(serviceId) // Use 'doc' instead of 'where' to get a single document
        .get();
    return documentSnapshot;
  } catch (e) {
    print('Error fetching service: $e');
    throw e;
  }
}

class UserBookingsScreen extends StatelessWidget {
  final String userId;

  const UserBookingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // Change this color to the desired color
          ),
          title: Text(
            AppLocalizations.of(context)!.yourBookings,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF03ADF6),
        ),
        body: Padding(
          padding: const EdgeInsets.all(2),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('userId', isEqualTo: userId)
                .orderBy('date',
                    descending:
                        true) // Order by 'date' field in descending order
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final List<Booking> bookings = snapshot.data!.docs
                  .map((doc) => Booking.fromFirebase(doc))
                  .toList();
              if (bookings.isEmpty) {
                return const Center(child: Text('No bookings found.'));
              }
              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Column(
                    children: [
                      ListTile(
                        title: FutureBuilder<DocumentSnapshot>(
                          future: fetchService(booking.serviceID),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData) {
                              return const Text('Service not found');
                            } else {
                              var serviceData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              var service = Service.fromSnapshot(serviceData,
                                  AppLocalizations.of(context)!.localeName);
                              if (service != null) {
                                return Text(
                                  service.name,
                                  style: const TextStyle(
                                    color: Color(0xFF03ADF6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else {
                                // If service is not found or null, return a default text
                                return const Text('Service not found');
                              }
                            }
                          },
                        ),
                        subtitle: Text(
                          '${AppLocalizations.of(context)!.date}: ${booking.date.toString()}, ${AppLocalizations.of(context)!.time}: ${booking.time.hourOfPeriod}:${booking.time.minute.toString().padLeft(2, '0')} ${booking.time.period == DayPeriod.am ? 'AM' : 'PM'}',
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        onTap: () {
                          // Add navigation to view details of the booking
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey[400],
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ));
  }
}
