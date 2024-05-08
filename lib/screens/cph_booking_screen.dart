import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:tophservices/models/booking_model.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/BookingDetailsScreen.dart';
import 'package:tophservices/widgets/hour_selection.dart';
import 'package:tophservices/widgets/maid_selection.dart';
import 'package:tophservices/widgets/custom_time_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';


class CphBookingScreen extends StatefulWidget {
  final Service service;
  final UserModel? currentuser;

  const CphBookingScreen({super.key, required this.service, this.currentuser});

  @override
  // ignore: library_private_types_in_public_api
  _CphBookingScreenState createState() => _CphBookingScreenState();
}

class _CphBookingScreenState extends State<CphBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _withMaterials = false; // Default to without materials
  double _selectedHour = 2.0;
  double _selectedMaid = 0.0;
  double _totalPrice = 0.0; // Initialize total price
  final TextEditingController _timeController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;
  void _handleHourSelection(double selectedHour) {
    setState(() {
      _selectedHour = selectedHour;
      _calculatePrice(); // Calculate total price when hour selection changes
    });
  }

  void _handleMaidSelection(double selectedMaidIndex) {
    setState(() {
      _selectedMaid = selectedMaidIndex + 1;
      _calculatePrice(); // Calculate total price when maid selection changes
    });
  }

  void _calculatePrice() async {
    _totalPrice = 0.0;
    double totalHours = _selectedHour * _selectedMaid;

    // Retrieve prices from the database based on the selected options
    double hourPrice = (widget.service.bookingOptions[_withMaterials
            ? 'withMaterials'
            : 'withoutMaterials']['hourPrice'] as int)
        .toDouble(); // Example prices

    // Calculate total price based on selected maids and hours
    double totalPrice = hourPrice * totalHours;

    // Update the state with the calculated total price
    setState(() {
      _totalPrice = totalPrice;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Color.fromRGBO(3, 173, 246, 1), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color.fromRGBO(3, 173, 246, 1), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color.fromRGBO(3, 173, 246, 1), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: _selectedDate = DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showCustomTimePicker(
      context: context,
      initialTime: _selectedTime,
      selectedDate: _selectedDate,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Update the text in the input field
        _timeController.text =
            '${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to the desired color
        ),
        title: Text(
          widget.service.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color.fromRGBO(3, 173, 246, 1),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   children: [
                  //     Text(
                  //       'Location:      ${widget.currentuser?.userLocation.buildingNumber}',
                  //       style: const TextStyle(
                  //           fontSize: 18, fontWeight: FontWeight.bold),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),

                  TextFormField(
                    style: const TextStyle(fontSize: 20),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration:  InputDecoration(
                      focusColor: const Color.fromRGBO(3, 173, 246, 1),
                      label: Text(
                       AppLocalizations.of(context)!.date,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1,
                            color: Colors
                                .black54), // Change the border color when focused
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .black), // Change the border color when focused and there's an error
                      ),
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Color.fromRGBO(3, 173, 246, 1),
                      ),
                    ),
                    controller: TextEditingController(
                        text: DateFormat('E, dd MMM yy').format(_selectedDate)),
                  ),
                  Row(
                    children: [
                       Text(
                        AppLocalizations.of(context)!.maidsnumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                          onPressed: () => _showInfoMessage(
                              context, 'Please select how many maids you want'),
                          icon: const Icon(Icons.help_outline_outlined))
                    ],
                  ),
                  MaidSelection(
                    onMaidSelected: _handleMaidSelection,
                  ),
                  Row(
                    children: [
                     Text(
                        AppLocalizations.of(context)!.cleaninghours,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                          onPressed: () => _showInfoMessage(context,
                              'Please select how many hours you want the maids'),
                          icon: const Icon(Icons.help_outline_outlined))
                    ],
                  ),
                  HourSelection(
                    onHourSelected: _handleHourSelection,
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: const TextStyle(fontSize: 20),
                    cursorColor: const Color.fromRGBO(3, 173, 246, 1),
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    decoration:  InputDecoration(
                      focusColor: const Color.fromRGBO(3, 173, 246, 1),
                      label: Text(
                         AppLocalizations.of(context)!.startingtime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Color.fromRGBO(3, 173, 246, 1),
                        ),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.watch_later_outlined,
                        color: Color.fromRGBO(3, 173, 246, 1),
                      ),
                    ),
                    controller: _timeController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _withMaterials = !_withMaterials;
                        _calculatePrice();
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 10, 10.0, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.clean_hands_sharp,
                                  color: Color.fromRGBO(3, 173, 246, 1),
                                  size: 50,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                 Text(
                                   AppLocalizations.of(context)!.withmaterils,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () =>
                                        _showMaterialsMessage(context),
                                    icon: const Icon(
                                      Icons.help_outline_outlined,
                                      color: Colors.black,
                                    )),
                                const SizedBox(
                                  width: 20,
                                ),
                                GFCheckbox(
                                  onChanged: (value) {
                                    setState(() {
                                      _withMaterials = value;
                                      _calculatePrice();
                                    });
                                  },
                                  value: _withMaterials,
                                  activeBgColor:
                                      const Color.fromRGBO(3, 173, 246, 1),
                                  size: GFSize.MEDIUM,
                                  type: GFCheckboxType.basic,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${ AppLocalizations.of(context)!.totalprice}: $_totalPrice ${AppLocalizations.of(context)!.aed}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    _validateFields(context);
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromRGBO(3, 173, 246, 1)),
                  ),
                  label:  Text(
                    AppLocalizations.of(context)!.next,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(
                    Icons.navigate_next_rounded,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validateFields(BuildContext context) {
    if (_selectedHour == 0.0 || _selectedMaid == 0.0) {
      _showErrorMessage(
        context,
        'Please select both hours and number of maids.',
      );
    } else if (_timeController.text.isEmpty) {
      _showErrorMessage(context, 'Please select a time.');
    } else if (widget.currentuser?.userLocation.buildingNumber == null ||
        widget.currentuser!.userLocation.buildingNumber.isEmpty) {
      _showErrorMessage(context, 'Please select a location.');
    } else {
      // All required fields are selected, proceed with booking
      final Booking booking = Booking(
        id: '', // Let Firestore generate the ID
        userId: widget.currentuser!.id,
        serviceName: widget.service.name,
        location: widget.currentuser!.userLocation,
        date: _selectedDate,
        time: _selectedTime,
        hours: _selectedHour,
        maidsCount: _selectedMaid.toInt(),
        withMaterials: _withMaterials,
        totalPrice: _totalPrice,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(booking: booking)),
      );
    }
  }

  void _bookService() {
    // Perform Firestore operation to add booking
    FirebaseFirestore.instance.collection('bookings').add({
      'userId': user!.uid, // Get user ID from Firebase Authentication
      'serviceName': widget.service.name,
      'date': _selectedDate,
      'time': {'hour': _selectedTime.hour, 'minute': _selectedTime.minute},
      'hours': _selectedHour,
      'maidsCount': _selectedMaid,
      'withMaterials': _withMaterials,
      'totalPrice': _totalPrice,
    }).then((value) {
      const AlertDialog(
        content: Text('Added Successfully'),
      );
      // Success, show a success message or navigate to another screen
    }).catchError((error) {
      // Handle error
      AlertDialog(
        content: Text('$error'),
      );
    });
  }
}

void _showErrorMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void _showInfoMessage(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 60, // Adjust the height as needed
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            message,
            style: const TextStyle(
              color: Color.fromRGBO(3, 173, 246, 1),
              fontSize: 16,
            ),
          ),
        )),
      );
    },
  );
}

void _showMaterialsMessage(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
          height: 330, // Adjust the height as needed
          child: Center(
            child: Column(children: [
              const Text(
                'Our Materials',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset('assets/materials-en.jpg'))
            ]),
          ));
    },
  );
}
