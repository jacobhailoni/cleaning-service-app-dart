import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tophservices/firebase_options.dart';
import 'package:tophservices/l10n/l10n.dart';
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/cph_booking_screen.dart';
import 'package:tophservices/screens/MapScreen.dart';
import 'package:tophservices/screens/home.dart';
import 'package:tophservices/screens/loginPage.dart';
import 'package:tophservices/screens/profile_screen.dart';
import 'package:tophservices/screens/splash_screen.dart';
import 'package:tophservices/screens/user_booking.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp( MyApp());
}

class MyApp extends StatefulWidget {
     MyApp({Key? key}) : super(key: key);

    @override
    _MyAppState createState() => _MyAppState();

    static void setLocale(BuildContext context, Locale newLocale){
      _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
      state?.setLocale(newLocale);
    }
}

class _MyAppState extends State<MyApp> {
    // Add your state variables here
    Locale? _locale;
    setLocale(Locale locale){
      setState(() {
        _locale = locale;
      });
    }

    @override
    void initState() {
    super.initState();
    // Initialize your state variables here
    }

    @override
    Widget build(BuildContext context) {
    return MaterialApp(
        supportedLocales: L10n.all,
        locale: _locale,
        localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
        ],
        debugShowCheckedModeBanner: false,
        title: 'Top H Services App',
        theme: ThemeData(fontFamily: 'Alegreya'),
        home: const SplashScreen(), // Check authentication status
        routes: {
        '/login': (context) => LoginPage(context: context),
        '/map': (context) {
            final String userId =
                ModalRoute.of(context)!.settings.arguments as String;
            return FutureBuilder<BookingLocation>(
                future: fetchUserLocation(userId),
                builder: (context, snapshot) {
                if (snapshot.hasData) {
                    return MapScreen(
                    currentUser: UserModel(
                        id: userId,
                        name: '',
                        email: '',
                        phoneNumber: '',
                        userLocation: BookingLocation(
                        location: snapshot.data!.location,
                        buildingNumber: snapshot.data!.buildingNumber,
                        apartmentNumber: snapshot.data!.apartmentNumber,
                        administrativeArea: snapshot.data!.administrativeArea,
                        ),
                    ),
                    onUpdateLocation: (BookingLocation) {},
                    navigateToHomePage: true,
                    );
                } else {
                    return Container();
                }
                });
        },
        '/home': (context) {
            final userId = ModalRoute.of(context)!.settings.arguments.toString();
            return GFHomeScreen(userId: userId, index: 0,);
        },
        '/booking': (context) {
            final Service service =
            ModalRoute.of(context)!.settings.arguments as Service;
            return CphBookingScreen(service: service);
        }, // Add route for the booking screen
        },
    );
    }
}

class GFHomeScreen extends StatefulWidget {
    final String userId;
    final int index;

    const GFHomeScreen({required this.userId, required this.index});

    @override
    _GFHomeScreenState createState() => _GFHomeScreenState();
}

class _GFHomeScreenState extends State<GFHomeScreen> {
    int _selectedIndex = 0;



    @override
    void initState() {
    super.initState();
    _selectedIndex = widget.index;
    FirebaseAuth.instance.authStateChanges().listen(
        (User? user) {
        if (user == null) {
            // User is not signed in, navigate to login screen
            Navigator.of(context).pushReplacementNamed('/login');
        }
        },
    );
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
        index: _selectedIndex,
        children: [
            HomePage(userId: widget.userId), // Pass the userId here
            UserBookingsScreen(userId: widget.userId),
            ProfileScreen(),
        ],
        ),
        bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 18,
        unselectedFontSize: 16,
        selectedItemColor: const Color.fromRGBO(3, 173, 246, 1),
        elevation: 20,
        unselectedItemColor: Colors.black38,
        items:  <BottomNavigationBarItem>[
            BottomNavigationBarItem(
            icon: const Icon(
                Icons.home_rounded,
            ),
            label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
            icon: const Icon(
                Icons.bookmark,
            ),
            label: AppLocalizations.of(context)!.bookings,
            ),
            BottomNavigationBarItem(
            icon: const Icon(
                Icons.account_circle,
            ),
            label: AppLocalizations.of(context)!.profile,
            ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        ),
    );
    }

    void _onItemTapped(int index) {
    if (index == _selectedIndex) {
        return;
    } else {
        setState(() {
        _selectedIndex = index;
        });
    }
    }
}

Future<BookingLocation> fetchUserLocation(String userId) async {
    try {
    // Reference to the user location document in Firestore
    DocumentSnapshot<Map<String, dynamic>> locationDoc =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if the document exists
    if (locationDoc.exists) {
        // Extract data from the document
        Map<String, dynamic> data = locationDoc.data()!;

        // Create a BookingLocation object from the data
        BookingLocation location = BookingLocation(
        location: data['location'] ?? '',
        buildingNumber: data['buildingNumber'] ?? '',
        apartmentNumber: data['apartmentNumber'] ?? '',
        administrativeArea: data['administrativeArea'] ?? '',
        );

        return location;
    } else {
        // Document does not exist
        throw Exception('User location not found for user ID: $userId');
    }
    } catch (error) {
    // Handle error
    print('Error fetching user location: $error');
    rethrow; // Re-throw the error for the caller to handle
    }
}