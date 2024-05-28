import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import 'admin_booking_details.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late DateTime selectedDate;
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _fetchBookingsForDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          _buildDatePickerButton(),
          GestureDetector(
            onTap: () {
              try {
                FirebaseAuth.instance.signOut();
                // Navigate back to the login page
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print("Error signing out: $e");
                // Handle sign-out error (e.g., show error message)
              }
            },
            child: const Icon(
              Icons.logout,
              size: 30,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton() {
    return TextButton(
      onPressed: _selectDate,
      child: Text(
        DateFormat('yyyy-MM-dd').format(selectedDate),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'No bookings for selected date',
        ),
      );
    } else {
      return ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['serviceName'],
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFF03ADF6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.area}: ${booking['location']['administrativeArea']}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.date}: ${booking['date']}, ${AppLocalizations.of(context)!.time}: ${booking['time']['hour']}:${booking['time']['minute'].toString().padLeft(2, '0')} ',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.maid}: ${booking['maidsCount']}, ${AppLocalizations.of(context)!.hours}: ${booking['hours'].toInt()} ',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.price} : ${booking['totalPrice']}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
                onTap: () {
                  // Add navigation to view details of the booking
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AdminBookingDetails(booking: booking)));
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
    }
  }

  Future<void> _fetchBookingsForDate(DateTime date) async {
    try {
      // Convert the selected date to the format stored in Firestore
      String formattedDate = DateFormat('d MMM yyyy').format(date);
      // Fetch bookings from Firestore for the selected date
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('bookings')
          .where('date', isEqualTo: formattedDate)
          .get();

      setState(() {
        // Clear previous bookings and add new ones
        bookings.clear();
        bookings.addAll(snapshot.docs.map((doc) => doc.data()));
      });
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _fetchBookingsForDate(selectedDate);
      });
    }
  }
}
