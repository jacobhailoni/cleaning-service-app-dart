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
    final UserModel? currentUser;

    const CphBookingScreen({super.key, required this.service, this.currentUser});

    @override
    // ignore: library_private_types_in_public_api
    _CphBookingScreenState createState() => _CphBookingScreenState();
}

class _CphBookingScreenState extends State<CphBookingScreen> {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool includeMaterials = false;
    double selectedHours = 2.0;
    double selectedMaids = 0.0;
    double totalPrice = 0.0;
    final TextEditingController timeController = TextEditingController();

    final user = FirebaseAuth.instance.currentUser;

    void _handleHourSelection(double selectedHour) {
    setState(() {
        selectedHours = selectedHour;
        _calculatePrice();
    });
    }

    void _handleMaidSelection(double selectedMaidIndex) {
    setState(() {
        selectedMaids = selectedMaidIndex + 1;
        _calculatePrice();
    });
    }

    void _calculatePrice() {
    totalPrice = 0.0;
    final totalHours = selectedHours * selectedMaids;

    final hourPrice = (widget.service.bookingOptions[includeMaterials
            ? 'withMaterials'
            : 'withoutMaterials']['hourPrice'] as int)
        .toDouble();

    totalPrice = hourPrice * totalHours;

    setState(() {
        totalPrice = totalPrice;
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
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
        setState(() {
        selectedDate = picked;
        });
    }
    }

    Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showCustomTimePicker(
        context: context,
        initialTime: selectedTime,
        selectedDate: selectedDate,
    );
    if (picked != null && picked != selectedTime) {
        setState(() {
        selectedTime = picked;
        timeController.text =
            '${selectedTime.hourOfPeriod}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? AppLocalizations.of(context)!.am : AppLocalizations.of(context)!.pm}';
        });
    }
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        iconTheme: const IconThemeData(
            color: Colors.white,
        ),
        title: Text(
            widget.service.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                    TextFormField(
                    style: const TextStyle(fontSize: 20),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
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
                        text: DateFormat(
                        'E, dd - MMM - yy',
                        Localizations.localeOf(context).toString(),
                    ).format(selectedDate)),
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
                        onPressed: () => _showInfoMessage(context,
                            AppLocalizations.of(context)!.infmesagemaids),
                        icon: const Icon(Icons.help_outline_outlined),
                        )
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
                                AppLocalizations.of(context)!.infmesagehours),
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
                    decoration: InputDecoration(
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
                    controller: timeController,
                    ),
                    const SizedBox(
                    height: 20,
                    ),
                    GestureDetector(
                    onTap: () {
                        setState(() {
                        includeMaterials = !includeMaterials;
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
                                    ),
                                ),
                                const SizedBox(
                                    width: 20,
                                ),
                                GFCheckbox(
                                    onChanged: (value) {
                                    setState(() {
                                        includeMaterials = value!;
                                        _calculatePrice();
                                    });
                                    },
                                    value: includeMaterials,
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
                    '${AppLocalizations.of(context)!.totalprice}: $totalPrice ${AppLocalizations.of(context)!.aed}',
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
                    label: Text(
                    AppLocalizations.of(context)!.next,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
    if (selectedHours == 0.0 || selectedMaids == 0.0) {
        _showErrorMessage(
        context,
        AppLocalizations.of(context)!.errmesageHoursMaids,
        );
    } else if (timeController.text.isEmpty) {
        _showErrorMessage(
        context,
        AppLocalizations.of(context)!.errmesageHours,
        );
    } else if (widget.currentUser?.userLocation.buildingNumber == null ||
        widget.currentUser!.userLocation.buildingNumber.isEmpty) {
        _showErrorMessage(
        context,
        AppLocalizations.of(context)!.errmesageLocation,
        );
    } else {
        // All required fields are selected, proceed with booking
        final Booking booking = Booking(
        id: '', // Let Firestore generate the ID
        userId: widget.currentUser!.id,
        serviceID: widget.service.id,
        location: widget.currentUser!.userLocation,
        date: DateFormat('dd MMM yyyy').format(selectedDate),
        time: selectedTime,
        hours: selectedHours,
        maidsCount: selectedMaids.toInt(),
        withMaterials: includeMaterials,
        totalPrice: totalPrice,
        );

        Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(booking: booking,serviceName: widget.service.name,)),
        );
    }
    }
}

void _showErrorMessage(BuildContext context, String message) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
        return AlertDialog(
        title: Text(AppLocalizations.of(context)!.alert),
        content: Text(message),
        actions: <Widget>[
            TextButton(
            onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text(AppLocalizations.of(context)!.ok),
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
        height: 200, // Adjust the height as needed
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
            ),
        ),
        );
    },
    );
}

void _showMaterialsMessage(BuildContext context) {
    showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
        return SizedBox(
        height: 350, // Adjust the height as needed
        child: Center(
            child: Column(
            children: [
                Text(
                AppLocalizations.of(context)!.ourmaterials,
                style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                        AppLocalizations.of(context)!.ourmaterialsImg))
            ],
            ),
        ),
        );
    },
    );
}