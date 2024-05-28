import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tophservices/OTPVerificationPage.dart';
import 'package:tophservices/auth_service.dart'; // Import AuthService for authentication logic
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/admin/admin_screen.dart';
import 'package:tophservices/screens/profileInfoScreen.dart'; // Import CompleteInfoPage

class LoginPage extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final AuthService _authService;

  LoginPage({required BuildContext context})
      : _authService = AuthService(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context)
                .size
                .height, // Ensure container takes full height
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 250,
                    height: 250,
                  ),
                  const Text(
                    'Top H Services',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    'The Best Cleaning Service in the UAE',
                    style: TextStyle(fontSize: 18, color: Colors.black45),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    cursorColor: const Color.fromRGBO(3, 173, 246, 1),
                    controller: phoneController,
                    style: const TextStyle(color: Colors.black87, fontSize: 18),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction
                        .done, // Set the text input action to 'done'
                    onSubmitted: (_) => _verifyPhoneNumber(
                        context), // Call verifyPhoneNumber method on submission
                    decoration: InputDecoration(
                      hintText: 'Enter Phone Number',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(3, 173, 246, 1),
                        ),
                      ),
                      prefixIcon: Container(
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/uae_flag.png',
                              width: 30,
                              height: 30,
                            ),
                            const Text(
                              '+971',
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: () => _verifyPhoneNumber(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.green, // Background color
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black, // Text color
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _loginWithFacebook(context),
                        icon: Image.asset(
                          'assets/facebook.png',
                          width: 30,
                          height: 30,
                        ),
                        label: const Text('Facebook'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      ElevatedButton.icon(
                        onPressed: () => _loginWithGoogle(context),
                        icon: Image.asset(
                          'assets/google.png',
                          width: 30,
                          height: 30,
                        ),
                        label: const Text('Google'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Authentication method for phone number login
  Future<void> _verifyPhoneNumber(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing dialog when tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Show circular loader
              SizedBox(height: 20),
              Text('Verifying Phone Number...'),
            ],
          ),
        );
      },
    );

    try {
      String phoneNumber = phoneController.text.trim();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+971$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieve verification code on some devices
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pop(context); // Dismiss dialog
          Navigator.pushReplacementNamed(context, '/home');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid phone number')),
            );
          } else {
            print('Error: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.pop(context); // Dismiss dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationPage(
                verificationId: verificationId,
                resendToken: resendToken,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieve timeout
        },
      );
    } catch (e) {
      print("Error verifying phone number: $e");
      // Dismiss dialog
      Navigator.pop(context);
    }
  }

  // Authentication method for Facebook login
  Future<void> _loginWithFacebook(BuildContext context) async {
    try {
      // Call signInWithFacebook method from AuthService
      final UserModel userModel = await _authService.signInWithFacebook();
      // Navigate to CompleteInfoPage after successful Facebook authentication
      if (checkAdmin(userModel.id) == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteInfoPage(
              user: userModel,
              firstTime: true,
            ), // Pass user object
          ),
        );
      }
    } catch (e) {
      // Handle login error
      print("Error logging in with Facebook: $e");
    }
  }

  // Authentication method for Google login
  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      // Call signInWithGoogle method from AuthService
      final UserModel userModel = await _authService.signInWithGoogle();
      bool isAdmin = await checkAdmin(userModel.id);
      // Navigate to CompleteInfoPage after successful Google authentication
      if (isAdmin) {
        print('True from inside');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteInfoPage(
              user: userModel,
              firstTime: true,
            ), // Pass user object
          ),
        );
      }
    } catch (e) {
      // Handle login error
      print("Error logging in with Google: $e");
    }
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
