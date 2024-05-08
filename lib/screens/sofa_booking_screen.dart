import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tophservices/models/booking_model.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/BookingDetailsScreen.dart';
import 'package:tophservices/widgets/custom_time_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';


class SofaBookingScreen extends StatefulWidget {
  final Service service;
  final UserModel? currentuser;
  const SofaBookingScreen({super.key, required this.service, this.currentuser});
  @override
  _SofaBookingScreenState createState() => _SofaBookingScreenState();
}

class _SofaBookingScreenState extends State<SofaBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _totalPrice = 0.0;
  int _totalSeats = 0;

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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                  const SizedBox(
                    height: 20,
                  ),
                  SofaSeatStepper(
                    seatNumber: _totalSeats,
                    onChanged: (int newValue) {
                      setState(() {
                        _totalSeats = newValue;
                      });
                      _calculatePrice();
                    },
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
                       AppLocalizations.of(context)!.time,
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
                  '${AppLocalizations.of(context)!.totalprice}: ${_totalPrice.toInt()} ${AppLocalizations.of(context)!.aed}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    _validateFields(context);
                  },
                  style: ButtonStyle(
                    alignment: Alignment.center,
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

  void _calculatePrice() async {
    _totalPrice = 0.0;

    // Retrieve prices from the database based on the selected options
    double seatPrice = (widget.service.bookingOptions['seatPrice'] as int)
        .toDouble(); // Example prices

    // Calculate total price based on selected maids and hours
    double totalPrice = seatPrice * _totalSeats;

    // Update the state with the calculated total price
    setState(() {
      _totalPrice = totalPrice;
    });
  }

  void _validateFields(BuildContext context) {
    if (_timeController.text.isEmpty) {
      _showErrorMessage(context, 'Please select a time.');
    } else {
      final Booking booking = Booking(
        id: '', // Let Firestore generate the ID
        userId: widget.currentuser!.id,
        serviceName: widget.service.name,
        location: widget.currentuser!.userLocation,
        date: _selectedDate,
        time: _selectedTime,
        hours: _totalSeats.toDouble(),
        maidsCount: 0,
        withMaterials: false,
        totalPrice: _totalPrice,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(booking: booking)),
      );
    }
    ;
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
              child:  Text(AppLocalizations.of(context)!.ok,),
            ),
          ],
        );
      },
    );
  }
}

class SofaSeatStepper extends StatefulWidget {
  final int seatNumber;
  final ValueChanged<int> onChanged;
  const SofaSeatStepper({
    Key? key,
    required this.seatNumber,
    required this.onChanged,
  }) : super(key: key);
  @override
  _SofaSeatStepperState createState() => _SofaSeatStepperState();
}

class _SofaSeatStepperState extends State<SofaSeatStepper> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              textAlign: TextAlign.start,
              AppLocalizations.of(context)!.sofaseats,
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(
                  () {
                    if (widget.seatNumber > 1) {
                      widget.onChanged(widget.seatNumber - 1);
                    }
                  },
                );
              },
              icon: const Icon(
                Icons.remove_circle,
                size: 30,
              ),
            ),
            Text(
              widget.seatNumber.toString(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                setState(
                  () {
                    if (widget.seatNumber < 30) {
                      widget.onChanged(widget.seatNumber + 1);
                    }
                  },
                );
              },
              icon: const Icon(
                Icons.add_circle,
                size: 30,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.chair_rounded,
              size: 50,
              color: Color.fromRGBO(3, 173, 246, 1),
            ),
          ],
        )
      ],
    );
  }
}
