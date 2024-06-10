import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:tophservices/widgets/CustomButton.dart';

import 'admin_booking_details.dart';

enum Provience {
  all('All', 'الكل'),
  dubai('Dubai', 'دبي'),
  abuDhabi('Abu Dhabi', 'ابوظبي'),
  sharjah('Sharjah', 'الشارقة'),
  ajman('Ajman', 'عجمان');

  const Provience(this.name, this.ar);
  final String name;
  final String ar;
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late DateTime selectedDate;
  Provience? selectedProvience;
  final TextEditingController _provienceController = TextEditingController();
  int todays = 0;
  int tommorow = 0;
  List<Map<String, dynamic>> todayBookings = [];
  List<Map<String, dynamic>> tomorrowBookings = [];
  late List<Map<String, dynamic>> filteredTodayBookings = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchAndAssignBookingsForToday(selectedDate);
    fetchAndAssignBookingsForTomorrow(
        selectedDate.add(const Duration(days: 1)));
    todays = todayBookings.length;
    tommorow = tomorrowBookings.length;
    print(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Todays Orders\n $todays',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF03ADF6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tomorrow Orders\n$tommorow',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownMenu<Provience>(
                        controller: _provienceController,
                        label: const Text('location'),
                        width: MediaQuery.of(context).size.width * 0.5,
                        dropdownMenuEntries:
                            Provience.values.map<DropdownMenuEntry<Provience>>(
                          (Provience prov) {
                            return DropdownMenuEntry(
                                value: prov, label: prov.name);
                          },
                        ).toList(),
                        requestFocusOnTap: false,
                        onSelected: (Provience? prov) {
                          setState(
                            () {
                              selectedProvience = prov;
                              if (prov!.name == "All") {
                                filteredTodayBookings = todayBookings;
                              } else {
                                filteredTodayBookings =
                                    filterListByArea(todayBookings, prov.name);
                              }
                            },
                          );
                          print(selectedProvience);
                        },
                      ),
                      _buildDatePickerButton(),
                    ],
                  )),
              Expanded(
                child: _buildBookingsList(),
              ),
            ],
          ),
        ));
  }

  Widget _buildDatePickerButton() {
    return CustomButton(
      onPressed: _selectDate,
      text: DateFormat('yyyy-MM-dd').format(selectedDate),
    );
  }

  Widget _buildBookingsList() {
    if (filteredTodayBookings.isEmpty) {
      return const Center(
        child: Text(
          'No bookings for selected date',
        ),
      );
    } else {
      return ListView.builder(
        itemCount: filteredTodayBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredTodayBookings[index];
          return Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder(
                      future: getServiceName(booking['serviceId'], context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const Text('Service not found');
                        }

                        // Display the service name
                        String serviceName = snapshot.data!;
                        return Text(
                          serviceName,
                          style: const TextStyle(
                            color: Color(0xFF03ADF6),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
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
                          AdminBookingDetails(booking: booking),
                    ),
                  );
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

  Future<List<Map<String, dynamic>>> fetchBookingsForDate(DateTime date) async {
    try {
      // Convert the selected date to the format stored in Firestore
      String formattedDate = DateFormat('dd MMM yyyy').format(date);

      // Fetch bookings from Firestore for the selected date
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('bookings')
          .where('date', isEqualTo: formattedDate)
          .get();

      // Return the fetched bookings data
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // Handle error
      print("Error fetching bookings: $e");
      return []; // Return empty list in case of error
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
      setState(
        () {
          selectedDate = pickedDate;
          filteredTodayBookings.clear();
          todayBookings.clear();
          fetchAndAssignBookingsForToday(pickedDate);
        },
      );
    }
  }

  Future<void> fetchAndAssignBookingsForToday(DateTime date) async {
    // Fetch bookings for the specified date
    List<Map<String, dynamic>> fetchedBookings =
        await fetchBookingsForDate(date);

    setState(() {
      todayBookings = fetchedBookings;
      filteredTodayBookings = todayBookings;
      todays = todayBookings.length;
    });
    // Assign fetched bookings to the bookings variable
  }

  Future<void> fetchAndAssignBookingsForTomorrow(DateTime date) async {
    // Fetch bookings for the specified date
    List<Map<String, dynamic>> fetchedBookings =
        await fetchBookingsForDate(date);

    // Assign fetched bookings to the bookings variable
    tomorrowBookings = fetchedBookings;
    tommorow = tomorrowBookings.length;
  }

  List<Map<String, dynamic>> filterListByArea(
      List<Map<String, dynamic>> dataList, String administrativeArea) {
    return dataList
        .where((data) =>
            data['location']['administrativeArea'] == administrativeArea)
        .toList();
  }

  Future<String> getServiceName(String serviceId, BuildContext context) async {
    try {
      // Get the current language code from the localization
      String languageCode = Localizations.localeOf(context).languageCode;

      // Construct the field name based on the language
      String fieldName = languageCode == 'ar' ? 'name_ar' : 'name_en';

      // Query Firestore to get the service document
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .get();

      // Check if the document exists and contains the field
      if (documentSnapshot.exists) {
        // Get the name from the document data
        String serviceName = documentSnapshot.get(fieldName);
        return serviceName;
      } else {
        // Return a default name if the document or field doesn't exist
        return 'Service Not Found';
      }
    } catch (e) {
      print('Error fetching service: $e');
      return 'Error';
    }
  }
}
