import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tophservices/models/booking_model.dart';
import 'package:tophservices/widgets/CustomButton.dart';

class BookingCompletionScreen extends StatelessWidget {
  final Booking booking;

  const BookingCompletionScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to the desired color
        ),
        title: const Text(
          'Booking Completed',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF03ADF6),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/booking_completed_image.png', // Your image asset
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Completed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Date: ${DateFormat('E, dd MMM yyyy').format(booking.date)}\nTime: ${booking.time.hourOfPeriod}:${booking.time.minute.toString().padLeft(2, '0')} ${booking.time.period == DayPeriod.am ? 'AM' : 'PM'}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                      arguments: booking.userId, // Pass userId as an argument
                    );
                  },
                  text: 'OK',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
