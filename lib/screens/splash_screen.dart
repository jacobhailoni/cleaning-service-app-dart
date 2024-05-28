import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tophservices/main.dart';
import 'package:tophservices/screens/loginPage.dart';

import 'admin/admin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Check authentication status after 3 seconds
    Future.delayed(
      Duration(seconds: 3),
      () {
        checkAuthentication();
      },
    );
  }

  void checkAuthentication() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is logged in, navigate to home page
      bool isAdmin = await checkAdmin(user.uid);
      if (isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GFHomeScreen(userId: user.uid, index: 0),
          ),
        );
      }
    } else {
      // If user is not logged in, navigate to login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(
            context: context,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            tileMode: TileMode.decal,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(3, 173, 246, 1),
              Color.fromRGBO(0, 191, 99, 1)
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
            ),
            Text(
              'Top H Services',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> checkAdmin(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (userSnapshot.exists) {
        // Check if the user is an admin based on the value of 'isAdmin' field
        bool isAdmin = userSnapshot.data()?['isAdmin'] ?? false;
        print(isAdmin);
        return isAdmin;
      } else {
        // If the document doesn't exist, user is not an admin
        return false;
      }
    } catch (e) {
      // Handle any potential errors
      print("Error checking admin status: $e");
      return false;
    }
  }
}
