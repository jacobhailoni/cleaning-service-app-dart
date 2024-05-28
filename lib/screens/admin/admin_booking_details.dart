import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:tophservices/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/booking_location_model.dart';

class AdminBookingDetails extends StatefulWidget {
  final Map<String, dynamic> booking;

  const AdminBookingDetails({Key? key, required this.booking})
      : super(key: key);

  @override
  _AdminBookingDetailsState createState() => _AdminBookingDetailsState();
}

class _AdminBookingDetailsState extends State<AdminBookingDetails> {
  late UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = UserModel(
        id: widget.booking['userId'],
        name: '',
        email: '',
        phoneNumber: '',
        userLocation: BookingLocation(
            location: '',
            buildingNumber: '',
            apartmentNumber: '',
            administrativeArea: ''));
    try {
      _loadUserData();
    } catch (e) {
      print('Error in initState: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.booking['serviceName'])),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context)!.bookingdetails,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.date,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    widget.booking['date'],
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.time,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${widget.booking['time']['hour']} : ${widget.booking['time']['minute']}',
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
              const Divider(
                height: 2,
                color: Colors.black45,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.maidsnumber,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${widget.booking['maidsCount']} ${AppLocalizations.of(context)!.maid}',
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.hours,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${widget.booking['hours']} ${AppLocalizations.of(context)!.hours}',
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.price,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${widget.booking['totalPrice']} ${AppLocalizations.of(context)!.aed}',
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const Divider(
                height: 2,
                color: Colors.black45,
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.bookingdetails,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.name,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    currentUser!.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.phone,
                    style: const TextStyle(fontSize: 20),
                  ),
                  GestureDetector(
                    onTap: () {
                      launchPhoneCall(currentUser!.phoneNumber);
                    },
                    child: Text(
                      currentUser!.phoneNumber,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.area,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    currentUser!.userLocation.administrativeArea,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.area,
                    style: const TextStyle(fontSize: 20),
                  ),
                  GestureDetector(
                    onTap: () {
                      Uri locationUrl =
                          Uri.parse(currentUser!.userLocation.location);
                      _launchUrl(locationUrl);
                    },
                    child: const Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.booking['userId'])
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userDataMap = userSnapshot.data()!;
        setState(() {
          currentUser = UserModel.fromMap(userDataMap);
        });
      } else {
        print('User data not found in Firestore');
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
  }

  Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    await launchUrl(launchUri);
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
