// ignore_for_file: library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/widgets/LocationInputField.dart';
import 'package:tophservices/widgets/serviceScreen.dart';
import 'package:tophservices/widgets/slider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

// Renamed fetchServices to getServices to better reflect the function's purpose.
Future<List<DocumentSnapshot>> getServices() async {
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
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Added comments to explain the purpose of each function
  UserModel?
      _currentUser; // Renamed to _currentUser to indicate its private nature

  // Initializes the user data, loads user information from local storage, and handles errors.
  @override
  void initState() {
    super.initState();
    _currentUser = UserModel(
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

  // Updates the user's location information and rebuilds the UI.
  void _updateLocationInfo(BookingLocation newLocation) {
    if (_currentUser != null) {
      setState(() {
        _currentUser!.userLocation = newLocation;
      });
    }
  }

  // Loads user data from Firebase Firestore and updates the UI.
  void _loadUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.id)
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userDataMap = userSnapshot.data()!;
        setState(() {
          _currentUser = UserModel.fromMap(userDataMap);
        });
      } else {
        print('User data not found in Firestore');
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
  }

  // Saves user data to local storage using SharedPreferences.
  // void _saveUserData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('userData', json.encode(_currentUser?.toMap()));
  // }

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
                      buildingName: _currentUser?.userLocation.buildingNumber,
                      apartmentNumber:
                          _currentUser?.userLocation.apartmentNumber,
                      onUpdateLocation: _updateLocationInfo,
                      currentUser: _currentUser,
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
                  Expanded(
                    child: FutureBuilder<List<DocumentSnapshot>>(
                      // Renamed fetchServices to getServices
                      future: getServices(),
                      builder: (context, snapshot) {
                        try {
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
                            List<Service> fetchedServices = [];
                            for (int index = 0;
                                index < snapshot.data!.length;
                                index++) {
                              Map<String, dynamic> serviceData =
                                  snapshot.data![index].data()
                                      as Map<String, dynamic>;
                              var service = Service.fromSnapshot(serviceData,
                                  AppLocalizations.of(context)!.localeName);
                              fetchedServices.add(service);
                            }
                            return ServicesScreen(services: fetchedServices, user: _currentUser);

                            // return ListView.builder(
                            // itemCount: snapshot.data!.length,
                            // itemBuilder: (context, index) {
                            //     Map<String, dynamic> serviceData =
                            //         snapshot.data![index].data()
                            //             as Map<String, dynamic>;
                            //     var service = Service.fromSnapshot(serviceData,
                            //         AppLocalizations.of(context)!.localeName);
                            //     return ServiceCard(
                            //         service: service, currentuser: _currentUser);
                            // },
                            // );
                          }
                        } catch (e) {
                          return Text('error $e');
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
