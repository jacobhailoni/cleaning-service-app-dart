import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/widgets/LocationInputField.dart';
import 'package:tophservices/widgets/service_card.dart';
import 'package:tophservices/widgets/slider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

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

class HomePage extends StatefulWidget {
  final String userId; // Accept user ID
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserModel? currentUser; // Change to nullable UserModel

  @override
  void initState() {
    super.initState();
    currentUser = UserModel(
        id: widget.userId,
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

  void _updateLocationInfo(BookingLocation newLocation) {
    if (currentUser != null) {
      setState(() {
        currentUser!.userLocation = newLocation;
      });
    }
  }

  // Load user data from local storage
  void _loadUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.id)
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

  // Save user data to local storage
  void _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(currentUser?.toMap()));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: screenHeight * 0.2 + kToolbarHeight,
                child: AppBar(
                  toolbarHeight: screenHeight * 0.2,
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 35),
                    child: LocationInputField(
                      currentUser: currentUser,
                      onUpdateLocation: _updateLocationInfo,
                    ),
                  ),
                  backgroundColor: const Color.fromRGBO(3, 173, 246, 1),
                  elevation: 0,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 35),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 0),
              child: Column(
                children: [
                  ImageSlider(),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  //   child: ImageSlider(),
                  // ),
                  // const Center(
                  //   child: Text(
                  //     'Our Services',
                  //     style:
                  //         TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  Expanded(
                    child: FutureBuilder<List<DocumentSnapshot>>(
                      future: fetchServices(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const GFLoader(
                            type: GFLoaderType.android,
                            loaderIconOne: Text('Please'),
                            loaderIconTwo: Text('Wait'),
                            loaderIconThree: Text('a moment'),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> serviceData =
                                  snapshot.data![index].data()
                                      as Map<String, dynamic>;

                              var service = Service.fromSnapshot(serviceData,
                                  AppLocalizations.of(context)!.localeName);
                              return ServiceCard(
                                  service: service, currentuser: currentUser);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
