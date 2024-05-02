import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:tophservices/models/booking_model.dart';
import 'package:tophservices/models/coupon_model.dart';
import 'package:tophservices/screens/booking_confirmation_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to the desired color
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF03ADF6),
      ),
      body: BookingDetailsForm(booking: booking),
    );
  }
}

class BookingDetailsForm extends StatefulWidget {
  final Booking booking;

  const BookingDetailsForm({super.key, required this.booking});

  @override
  // ignore: library_private_types_in_public_api
  _BookingDetailsFormState createState() => _BookingDetailsFormState();
}

Future<List<Coupon>> fetchCouponsFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('coupons').get();

    List<Coupon> coupons =
        querySnapshot.docs.map((doc) => Coupon.fromFirestore(doc)).toList();
    // print(coupons.length);

    return coupons;
  } catch (e) {
    print('Error fetching coupons: $e');
    return [];
  }
}

class _BookingDetailsFormState extends State<BookingDetailsForm> {
  final TextEditingController _couponController = TextEditingController();
  double _discount = 0.0;
  double finalPrice = 0;
  // ignore: non_constant_identifier_names
  String payment_meth = 'cash';

  late Stream<List<Coupon>> _couponsStream;

  @override
  void initState() {
    super.initState();
    // Fetch and store coupons when the screen is initialized
    _couponsStream = FirebaseFirestore.instance
        .collection('coupons')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Coupon.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return StreamBuilder<List<Coupon>>(
      stream: _couponsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while fetching data
        }
        if (snapshot.hasError) {
          return Text('Error fetching coupons: ${snapshot.error}');
        }
        List<Coupon> coupons = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GFTypography(
                                text: 'Booking Summary',
                                showDivider: false,
                                type: GFTypographyType.typo1,
                                fontWeight: FontWeight.bold,
                                textColor: Color.fromRGBO(3, 173, 246, 1),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.home_repair_service_outlined,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Service Name: ${booking.serviceName}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              // Display booking details using booking object
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range_sharp,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${DateFormat('E, dd MMM yy').format(booking.date)} - ${booking.time.hourOfPeriod}:${booking.time.minute.toString().padLeft(2, '0')} ${booking.time.period == DayPeriod.am ? 'AM' : 'PM'}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Column(
                                children: [
                                  if (booking.serviceName ==
                                      'Cleaning Per Hour')
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.alarm,
                                              size: 30,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${booking.hours.toInt()} Hours',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person_2_sharp,
                                              size: 30,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${booking.maidsCount} Maid/s',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.clean_hands_sharp,
                                              size: 30,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              booking.withMaterials
                                                  ? 'With Materials'
                                                  : 'Without Materials',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    )
                                  else if (booking.serviceName ==
                                      'Sofa Cleaning')
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.chair_rounded,
                                              size: 30,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${booking.hours} Seats',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ],
                              ),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      booking.location.buildingNumber,
                                      style: const TextStyle(fontSize: 15),
                                      softWrap: true,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const GFTypography(
                                text: 'Payment Method:',
                                showDivider: false,
                                type: GFTypographyType.typo1,
                                fontWeight: FontWeight.bold,
                                textColor: Color.fromRGBO(3, 173, 246, 1),
                              ),
                              GFCard(
                                margin: const EdgeInsets.all(2),
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 4),
                                content: RadioListTile(
                                  activeColor:
                                      const Color.fromRGBO(3, 173, 246, 1),
                                  value: 'cash',
                                  groupValue: payment_meth,
                                  onChanged: (value) {
                                    setState(() {
                                      payment_meth = value!;
                                    });
                                  },
                                  title: const Text(
                                    'Cash On Service',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              GFCard(
                                margin: const EdgeInsets.all(2),
                                color: Colors.white60,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 2),
                                content: IgnorePointer(
                                  ignoring:
                                      true, // This will disable user interaction
                                  child: RadioListTile(
                                    secondary: const Text('Coming soon'),
                                    activeColor:
                                        const Color.fromRGBO(3, 173, 246, 1),
                                    value: 'online',
                                    groupValue: payment_meth,
                                    onChanged: (value) {
                                      // This won't be called as the widget is disabled
                                    },
                                    title: const Text(
                                      'Credit Card/Online',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 10, 10.0, 10),
                                  child: Wrap(
                                    spacing: 20,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: TextFormField(
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                            readOnly: false,
                                            decoration: const InputDecoration(
                                              focusColor: Color.fromRGBO(
                                                  3, 173, 246, 1),
                                              label: Text(
                                                'Enter Coupon',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 2,
                                                    color: Color.fromRGBO(
                                                        3,
                                                        173,
                                                        246,
                                                        1)), // Change the border color when focused
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .black), // Change the border color when focused and there's an error
                                              ),
                                            ),
                                            controller: _couponController),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 1),
                                        child: GFButton(
                                          color: const Color.fromRGBO(
                                              3, 173, 246, 1),
                                          padding: const EdgeInsets.all(5),
                                          onPressed: () {
                                            _applyCoupon(coupons);
                                          },
                                          child: const Icon(
                                            Icons.done,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: ${booking.totalPrice.toInt()}  AED',
                              style: const TextStyle(fontSize: 20)),
                          Text(
                              'Discount:  ${(booking.totalPrice * _discount) ~/ 100}   AED  -',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.green)),
                          Text(
                              'Final Price: ${booking.totalPrice - (_discount * booking.totalPrice / 100)}   AED',
                              style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                _bookService();
                              },
                              style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white), // Text color
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      const Color.fromRGBO(3, 173, 246, 1))),
                              icon: const Icon(
                                Icons.bookmark_add_rounded,
                                size: 40,
                              ),
                              label: const Text(
                                'Book Now',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _bookService() {
    FirebaseFirestore.instance.collection('bookings').add({
      'userId': widget.booking.userId,
      'serviceName': widget.booking.serviceName,
      'location': {
        'location': widget.booking.location.location,
        'buildingNumber': widget.booking.location.buildingNumber,
        'apartmentNumber': widget.booking.location.apartmentNumber,
        'administrativeArea': widget.booking.location.administrativeArea,
      },
      'date': widget.booking.date,
      'time': {
        'hour': widget.booking.time.hour,
        'minute': widget.booking.time.minute,
      },
      'hours': widget.booking.hours,
      'maidsCount': widget.booking.maidsCount,
      'withMaterials': widget.booking.withMaterials,
      'totalPrice': widget.booking.totalPrice,
    }).then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BookingCompletionScreen(booking: widget.booking),
        ),
      );
    }).catchError((error) {
      _showErrorDialog(error);
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Booking added successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to add booking: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _applyCoupon(List<Coupon> coupons) {
    String couponCode = _couponController.text.trim();
    if (couponCode.isNotEmpty) {
      // Find the coupon with the entered code
      Coupon? coupon = coupons.firstWhere(
        (coupon) => coupon.code == couponCode,
        orElse: () => Coupon(id: '', code: 'code', discountPercentage: 0),
      );

      if (coupon.discountPercentage != 0) {
        // Apply discount if coupon is found
        setState(() {
          _discount = coupon.discountPercentage.toDouble();
        });
      } else {
        // Handle invalid coupon code
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Coupon'),
            content: const Text('The entered coupon code is invalid.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
