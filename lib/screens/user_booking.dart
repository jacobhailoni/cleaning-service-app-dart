import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tophservices/models/booking_model.dart';

class UserBookingsScreen extends StatelessWidget {
  final String userId;

  const UserBookingsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // Change this color to the desired color
          ),
          title: Text(
            'Your Bookings',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF03ADF6),
        ),
        body: Padding(
          padding: EdgeInsets.all(2),
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
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final List<Booking> bookings = snapshot.data!.docs
                  .map((doc) => Booking.fromFirebase(doc))
                  .toList();
              if (bookings.isEmpty) {
                return Center(child: Text('No bookings found.'));
              }
              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          booking.serviceName,
                          style: TextStyle(
                            color: Color(0xFF03ADF6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Date: ${DateFormat('E, dd MMM yyyy').format(booking.date)}, Time: ${booking.time.hourOfPeriod}:${booking.time.minute.toString().padLeft(2, '0')} ${booking.time.period == DayPeriod.am ? 'AM' : 'PM'}',
                          style: TextStyle(
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
